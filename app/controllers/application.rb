class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem
  include RoleRequirementSystem

  helper :all # include all helpers, all the time
  protect_from_forgery :secret => 'b0a876313f3f9195e9bd01473bc5cd06'
  filter_parameter_logging :password, :password_confirmation
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  before_filter :set_locale

  def set_locale
    # update session if passed
    # session[:locale] = params[:locale] if params[:locale]
    new_locale = extract_locale_from_params
    session[:locale] = new_locale if new_locale

    # set locale based on session or default
    I18n.locale = session[:locale] || I18n.default_locale
    logger.debug "Locale set to '#{I18n.locale}'"
  end

  protected
  
  def extract_locale_from_params
    (AVAILABLE_LOCALES.include? params[:locale]) ? params[:locale]  : nil
  end

  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
  end
end

