module Api
  module V1
    module Admin
      class OrdersController < BaseController
        def index
          orders = Order.includes(:user, :order_items, :products)
                        .order(created_at: :desc)
                        .page(params[:page]).per(params[:per_page] || 20)
          render json: orders.as_json(include: [:user, { order_items: { include: :product } }])
        end

        def show
          render json: order.as_json(include: [:user, { order_items: { include: :product } }])
        end

        def update
          order.update!(status: params.require(:order).permit(:status)[:status])
          render json: order
        end

        private

        def order
          @order ||= Order.find(params[:id])
        end
      end
    end
  end
end
