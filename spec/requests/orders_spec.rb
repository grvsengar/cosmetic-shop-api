require "rails_helper"

RSpec.describe "Orders", type: :request do
  let!(:user)    { create(:user) }
  let!(:product) { create(:product, price: 500.0, stock_count: 10) }

  def auth_header
    post "/api/v1/auth/sign_in",
         params: { user: { email: user.email, password: "Password123!" } },
         as: :json
    { "Authorization" => response.headers["Authorization"] }
  end

  before do
    # Stub Razorpay so tests don't hit the network
    fake_rzp_order = double(
      "Razorpay::Order",
      id:       "order_test123",
      amount:   50_000,
      currency: "INR"
    )
    allow(Razorpay::Order).to receive(:create).and_return(fake_rzp_order)
  end

  describe "POST /api/v1/orders" do
    let(:valid_params) do
      {
        order: {
          address: "123 MG Road, Bhopal",
          items:   [{ product_id: product.id, quantity: 2 }]
        }
      }
    end

    it "creates an order and returns Razorpay checkout params" do
      post "/api/v1/orders", params: valid_params, headers: auth_header, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["order"]["status"]).to eq("pending")
      expect(json["razorpay"]["order_id"]).to eq("order_test123")
      expect(json["razorpay"]["amount"]).to eq(100_000)   # 2 × ₹500 in paise
      expect(json["razorpay"]["currency"]).to eq("INR")
    end

    it "decrements stock on order creation" do
      post "/api/v1/orders", params: valid_params, headers: auth_header, as: :json

      expect(product.reload.stock_count).to eq(8)
    end

    it "returns 422 when stock is insufficient" do
      params = {
        order: {
          address: "123 MG Road, Bhopal",
          items:   [{ product_id: product.id, quantity: 99 }]
        }
      }
      post "/api/v1/orders", params: params, headers: auth_header, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(product.reload.stock_count).to eq(10)   # not decremented
    end

    it "returns 401 for unauthenticated requests" do
      post "/api/v1/orders", params: valid_params, as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 422 when address is missing" do
      params = {
        order: {
          address: "",
          items:   [{ product_id: product.id, quantity: 1 }]
        }
      }
      post "/api/v1/orders", params: params, headers: auth_header, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/orders" do
    before { create(:order, user: user) }

    it "returns the current user's orders" do
      get "/api/v1/orders", headers: auth_header

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
    end

    it "does not return another user's orders" do
      other_order = create(:order, user: create(:user))
      get "/api/v1/orders", headers: auth_header

      ids = JSON.parse(response.body).map { |o| o["id"] }
      expect(ids).not_to include(other_order.id)
    end
  end
end
