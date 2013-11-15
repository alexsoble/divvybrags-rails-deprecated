class ApplicationController < ActionController::Base
  protect_from_forgery

  after_filter :set_access_control_headers

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = 'chrome-extension://hjholnjdmkpijohoabkjdeffdpidlmei/'
    headers['Access-Control-Request-Method'] = 'chrome-extension://hjholnjdmkpijohoabkjdeffdpidlmei/'
  end

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
  end
  
end
