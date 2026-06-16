module Api
  module V1
    module Auth
      class FailureApp < Devise::FailureApp
        def respond
          json_failure
        end

        def json_failure
          self.status = 401
          self.content_type = "application/json"
          self.response_body = { error: i18n_message }.to_json
        end
      end
    end
  end
end
