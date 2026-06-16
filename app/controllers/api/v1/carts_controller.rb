module Api
  module V1
    class CartsController < BaseController
      before_action :load_or_create_cart

      # GET /api/v1/cart
      def show
        render json: cart_json
      end

      # POST /api/v1/cart/items  { product_id:, quantity: }
      def add_item
        product = Product.find(params[:product_id])
        quantity = params[:quantity].to_i
        quantity = 1 if quantity < 1

        raise "Only #{product.stock_count} left in stock" if quantity > product.stock_count

        item = @cart.cart_items.find_or_initialize_by(product: product)

        new_qty = item.new_record? ? quantity : item.quantity + quantity
        raise "Only #{product.stock_count} left in stock" if new_qty > product.stock_count

        item.quantity = new_qty
        item.save!

        render json: cart_json, status: item.previously_new_record? ? :created : :ok
      end

      # PATCH /api/v1/cart/items/:product_id  { quantity: }
      def update_item
        item = @cart.cart_items.find_by!(product_id: params[:product_id])
        quantity = params[:quantity].to_i

        raise "Only #{item.product.stock_count} left in stock" if quantity > item.product.stock_count

        item.update!(quantity: quantity)
        render json: cart_json
      end

      # DELETE /api/v1/cart/items/:product_id
      def remove_item
        @cart.cart_items.find_by!(product_id: params[:product_id]).destroy!
        render json: cart_json
      end

      # DELETE /api/v1/cart
      def destroy
        @cart.cart_items.destroy_all
        render json: cart_json
      end

      private

      def load_or_create_cart
        @cart = current_user.cart || current_user.create_cart!
      end

      def cart_json
        {
          id: @cart.id,
          item_count: @cart.item_count,
          total: @cart.total.to_f,
          items: @cart.cart_items.includes(:product).map { |item|
            {
              id: item.id,
              product_id: item.product_id,
              product_name: item.product.name,
              product_price: item.product.price.to_f,
              quantity: item.quantity,
              subtotal: item.subtotal.to_f
            }
          }
        }
      end
    end
  end
end
