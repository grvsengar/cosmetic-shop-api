require "rails_helper"

RSpec.describe "Auth", type: :request do
  describe "POST /api/v1/auth/sign_in" do
    let!(:user) { create(:user, email: "test@example.com", password: "Password123!") }

    it "returns a JWT token on valid credentials" do
      post "/api/v1/auth/sign_in", params: { user: { email: "test@example.com", password: "Password123!" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to match(/\ABearer .+\z/)
      json = JSON.parse(response.body)
      expect(json.dig("user", "email")).to eq("test@example.com")
    end

    it "returns 401 on wrong password" do
      post "/api/v1/auth/sign_in", params: { user: { email: "test@example.com", password: "wrong" } }, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    let!(:user) { create(:user) }

    it "revokes the JWT so subsequent requests with that token return 401" do
      post "/api/v1/auth/sign_in", params: { user: { email: user.email, password: "Password123!" } }, as: :json
      token = response.headers["Authorization"]

      delete "/api/v1/auth/sign_out", headers: { "Authorization" => token }
      expect(response).to have_http_status(:ok)

      get "/api/v1/orders", headers: { "Authorization" => token }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "admin-only routes" do
    let!(:customer) { create(:user) }
    let!(:admin)    { create(:user, :admin) }

    def auth_header(u)
      post "/api/v1/auth/sign_in", params: { user: { email: u.email, password: "Password123!" } }, as: :json
      { "Authorization" => response.headers["Authorization"] }
    end

    it "returns 403 when a customer hits an admin endpoint" do
      get "/api/v1/admin/products", headers: auth_header(customer)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 200 when an admin hits an admin endpoint" do
      get "/api/v1/admin/products", headers: auth_header(admin)
      expect(response).to have_http_status(:ok)
    end
  end
end
