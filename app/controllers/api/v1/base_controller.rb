module Api
  module V1
    class BaseController < ActionController::API
      resource_description do
        api_version "1"
      end
    end
  end
end
