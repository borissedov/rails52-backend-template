class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :add_cors_headers

  protected

  rescue_from ArgumentError do |e|
    render :json => {:ErrorType => 'Validation Error', :message => e.message},
           :code => :bad_request
  end

  def after_sign_in_path_for(resource)
    rails_admin.dashboard_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation, :name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :password, :password_confirmation, :current_password, :name])
  end

  private

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def add_cors_headers
    response.set_header('Access-Control-Allow-Credentials', 'true')
  end
end
