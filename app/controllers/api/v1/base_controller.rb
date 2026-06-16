module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable
      rescue_from RuntimeError, with: :unprocessable_message

      private

      def not_found(e)
        render json: { error: e.message }, status: :not_found
      end

      def unprocessable(e)
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      def unprocessable_message(e)
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end
  end
end
