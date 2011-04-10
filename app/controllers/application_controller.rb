class ApplicationController < ActionController::Base
  include SessionsHelper
  protect_from_forgery

  before_filter :authenticate
  
  def generate_password(length=6)
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    password = ''
    length.times { |i| password << chars[rand(chars.length)] }
    password
  end
end
