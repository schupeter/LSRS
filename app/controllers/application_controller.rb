# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  before_filter :header_iso
  protect_from_forgery

  def header_iso
    response.headers['Content-type'] = 'text/html; charset=ISO-8859-1'
  end

end
