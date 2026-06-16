module Api
  module V1
    class OrdersController < BaseController
      def index
        orders = current_user.orders.includes(:order_items, :products).order(created_at: :desc)
        render json: orders.as_json(include: { order_items: { include: :product } })
      end

      def show
        order = current_user.orders.find(params[:id])
        render json: order.as_json(include: { order_items: { include: :product } })
      end

      def create
        result = Orders::CreateService.call(current_user, order_params)

        if result.success?
          render json: {
            order: result.order.as_json(include: { order_items: { include: :product } }),
            razorpay: {
              key_id:   result.razorpay_key_id,
              order_id: result.order.razorpay_order_id,
              amount:   (result.order.total * 100).to_i,
              currency: "INR",
              name:     "Cosmetic Shop Bhopal",
              prefill:  { email: current_user.email }
            }
          }, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

      def order_params
        params.require(:order).permit(:address, items: [:product_id, :quantity])
      end
    end
  end
end
