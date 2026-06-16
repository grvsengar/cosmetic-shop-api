module Api
  module V1
    class ProductsController < ApplicationController
      def index
        products = Product.includes(:category, images_attachments: :blob)
        products = products.where(category: Category.find_by(slug: params[:category])) if params[:category]
        products = products.in_stock if params[:in_stock] == "true"
        products = products.page(params[:page]).per(params[:per_page] || 20)

        render json: products.as_json(include: :category, methods: :image_urls)
      end

      def show
        product = Product.includes(:category, images_attachments: :blob).find(params[:id])
        render json: product.as_json(include: :category, methods: :image_urls)
      end
    end
  end
end
