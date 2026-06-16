module Api
  module V1
    module Auth
      class SessionsController < Devise::SessionsController
        respond_to :json

        # Devise calls this in after_action; skip it in API mode — no flash/session
        def verify_signed_out_user; end

        private

        def respond_with(resource, _opts = {})
          render json: { user: resource.as_json(only: [:id, :email, :role]) }, status: :ok
        end

        def respond_to_on_destroy(*)
          render json: { message: "Signed out successfully" }, status: :ok
        end
      end
    end
  end
end
