module SessionsHelper
  
  def authenticate(user)
    if signed_in?
      # check and/or refresh session ..
    else
      # redirect to login ..
    end
  end
  
  def sign_in(user)
    session[:remember_token] = user.id
    refresh_session
    self.current_user = user
  end
  
  def refresh_session
    session[:ends] = Time.now.utc + LOGIN_SESSION_LENGTH
  end
  
  def signed_in? 
    !current_user.nil?
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= User.find session[:remember_token]
  end
end
