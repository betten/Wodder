# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :set_user
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  private

  def set_user
	if session[:user_id]
		@user = User.find(:first, :conditions => { :id => session[:user_id] })
	end
  end

end
