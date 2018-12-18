module Api
  module V1
    class PasswordsController < Devise::PasswordsController
      skip_before_action :verify_authenticity_token

      respond_to :json


      api :POST, '/v1/passwords'
      param :email, String, :required => true
      def create
        @user = User.find_by_email(params[:email])

        if @user.blank?
          return render :json => {:success => false, :message => "Email doesn't belong to any account."}, status: 500
        else
          @user.send_reset_password_instructions

          if successfully_sent?(@user)
            return render :json => {:success => true}
          else
            return render :json => {:success => false}, status: 500
          end
        end
      end

      api :PUT, '/v1/passwords'
      param :reset_code, String, :required => true
      param :password, String, :required => true
      param :password_confirmation, String, :required => true
      def update
        reset_code = params['reset_code']
        reset_password_token = Devise.token_generator.digest(self, :reset_password_token, reset_code)
        user = User.find_by reset_password_token: reset_password_token
        if user == nil
          return render :json => { :success => false, :message => 'Unable to find user' }
        end
        if user.reset_password_sent_at < 1.hour.ago
          return render :json => { :success => false, :message => 'Password Token has now expired' }
        elsif user.update_attributes(:password => params[:password], :password_confirmation => params[:password_confirmation])
          return render :json => { :success => true, :message => 'Password has been updated'}
        else
          return render :json => { :success => false, :message => 'Unknown error has occured' }
        end
      end
    end
  end
end