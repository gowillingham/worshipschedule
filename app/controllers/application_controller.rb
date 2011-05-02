class ApplicationController < ActionController::Base
  include SessionsHelper
  protect_from_forgery

  before_filter :authenticate
  before_filter :check_account
end
