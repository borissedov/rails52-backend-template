module Api
  module V1
    class SessionsController < DeviseController
      skip_before_action :verify_authenticity_token

      respond_to :json

      api :POST, '/v1/auth/sign_in'
      param :email, String, :required => true
      param :password, String, :required => true
      # param :device_type, DeviceRegistration.device_types
      # param :device_token, String

      def create
        resource = User.find_for_database_authentication(:email => params[:email])
        return invalid_login_attempt unless resource

        if resource.valid_password?(params[:password])
          sign_in(resource_name, resource)

          # if params[:device_token].present?
          #   DeviceRegistrationService.new(user_id: resource.id, device_type: params[:device_type], device_token: params[:device_token]).register_device
          # end

          render :json => {:user => resource}
          return
        end
        invalid_login_attempt
      end

      api :DELETE, '/v1/auth/sign_in'

      def destroy
        sign_out(resource_name)
        render :json => {:success => true}
      end

      protected

      def invalid_login_attempt
        warden.custom_failure!
        render :json => {
            :success => false,
            :message => 'Error with your login or password'
        }, :status => 401
      end
    end
  end
end
