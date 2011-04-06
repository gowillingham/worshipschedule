module SessionsHelper
  
  def authenticate
    if signed_in?
      # check and/or refresh session ..
    else
      flash[:error] = "Can't show you that page until you sign in!"
      redirect_to signin_path
    end
  end
  
  def sign_in(user)
    session[:user_id] = user.id
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
    @current_user ||= User.find_by_id session[:user_id]
  end
  
  def sign_out
    reset_session
    self.current_user = nil
  end
end
