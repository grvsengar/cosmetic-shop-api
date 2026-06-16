module Api
  module V1
    module Admin
      class CategoriesController < BaseController
        def index
          render json: Category.all
        end

        def show
          render json: category
        end

        def create
          cat = Category.create!(category_params)
          render json: cat, status: :created
        end

        def update
          category.update!(category_params)
          render json: category
        end

        def destroy
          category.destroy!
          head :no_content
        end

        private

        def category
          @category ||= Category.find(params[:id])
        end

        def category_params
          params.require(:category).permit(:name, :slug)
        end
      end
    end
  end
end
