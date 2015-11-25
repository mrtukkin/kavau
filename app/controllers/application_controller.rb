#TODO setup mailer
#TODO forbid creating payments if end_of_year balance has not been compleeted
require 'application_responder'

class ApplicationController < ActionController::Base
  include Pundit
  include I18nKeyHelper
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  #rescue_from DefaultAccountMissingError, with: :missing_address_information
  #rescue_from LegalInformationMissingError, with: :missing_address_information
  #rescue_from ContactMissingError, with: :missing_address_information
  rescue_from MissingInformationError, with: :missing_address_information

  self.responder = ApplicationResponder
  respond_to :html

  before_action :authenticate_user!
  before_action :set_back_url, only: [:index, :show]
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index

  protect_from_forgery with: :exception

  private
    def set_back_url
      session[:back_url] = url_for(controller: controller_name,
                                   action: action_name,
                                   only_path: true)
    end

    def user_not_authorized
      flash[:alert] = I18n.t('helpers.not_auhtorized')
      redirect_to(request.referrer || root_path)
    end

    def missing_address_information(exception)
      redirect_to exception.address
    end
end
