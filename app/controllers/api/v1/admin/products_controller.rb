module Api
  module V1
    module Admin
      class ProductsController < BaseController
        def index
          products = Product.includes(:category).page(params[:page]).per(params[:per_page] || 20)
          render json: products.as_json(include: :category, methods: :image_urls)
        end

        def show
          render json: product.as_json(include: :category, methods: :image_urls)
        end

        def create
          product = Product.new(product_params)
          product.save!
          render json: product, status: :created
        end

        def update
          product.update!(product_params)
          render json: product
        end

        def destroy
          product.destroy!
          head :no_content
        end

        private

        def product
          @product ||= Product.find(params[:id])
        end

        def product_params
          params.require(:product).permit(:name, :description, :price, :stock_count, :category_id, images: [])
        end
      end
    end
  end
end
