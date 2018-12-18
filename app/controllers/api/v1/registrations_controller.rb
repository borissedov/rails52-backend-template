module Api
  module V1
    # require 'device_registraion_service'

    class RegistrationsController < DeviseController
      skip_before_action :verify_authenticity_token

      before_action :authenticate_user!, :only => [:update]

      respond_to :json

      api :POST, '/v1/auth'
      param :email, String, :required => true
      param :password, String, :required => true
      param :password_confirmation, String, :required => true
      param :name, String, :required => true, limit: 30
      # param :device_type, DeviceRegistration.device_types
      # param :device_token, String

      def create
        if User.where(:email => params[:email]).first.present?
          return render :json => {
              :success => false, :message => 'Email already exists' }, status: 422
        end


        resource = User.new(:email => params[:email],
                            :password => params[:password],
                            :password_confirmation => params[:password_confirmation],
                            :name => params[:name]
        )

        if resource.save
          sign_in('user', resource)

          # if params[:device_token].present?
          #   DeviceRegistrationService.new(user_id: resource.id, device_type: params[:device_type], device_token: params[:device_token]).register_device
          # end

          render :json => {
              :success => true,
              :data => resource
          }
        else
          clean_up_passwords resource
          render :json => {
              :success => false,
              :message => resource.errors.full_messages.collect.compact
          }
        end
      end

      api :PUT, '/v1/auth'
      param :email, String
      param :current_password, String
      param :password, String
      param :password_confirmation, String
      param :name, String, limit: 30
      param :avatar, ActionDispatch::Http::UploadedFile

      def update
        resource = User.find(current_user.id)
        new_email_user = User.find_by(email: user_params[:email])
        if new_email_user.present? && new_email_user.id != resource.id
          return render :json => {
              :success => false,
              :message => 'User with this email already exists'
          }
        end

        if(user_params[:password].present?)
          resource_updated = resource.update_with_password(user_params)
        else
          resource_updated = resource.update(user_params)
        end
        if resource_updated
          bypass_sign_in resource

          render :json => {
              :success => resource_updated,
              :data => resource.as_json(methods: [:avatar_url])
          }
        else
          render :json => {
              :success => false,
              :message => resource.errors.full_messages.collect.compact
          }
        end
      end


      api :DELETE, '/v1/auth'

      def destroy
        User.destroy(current_user)

        render :json => {
            :success => true
        }
      end

      private

      def user_params
        params.permit(:email, :current_password, :password, :password_confirmation, :name, :avatar)
      end
    end
  end
end