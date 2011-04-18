module SessionsHelper
  
  def authenticate
    if signed_in?
      check_session
    else
      boot_session
    end
  end
  
  def check_session
    if (Time.now.utc - session[:starts]) > LOGIN_SESSION_LENGTH
      boot_session
    else
      refresh_session
    end
  end
  
  def boot_session
    sign_out
    flash[:error] = "Can't show you that page until you sign in!"
    redirect_to signin_path
  end
  
  def sign_in(user)
    session[:user_id] = user.id
    refresh_session
    self.current_user = user
  end
  
  def refresh_session
    session[:starts] = Time.now.utc
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
  
  def current_account=(account)
    @current_account = account
  end
  
  def current_account
    @current_account ||= Account.find_by_id session[:account_id]
  end
  
  def sign_out
    reset_session
    self.current_user = nil
    self.current_account = nil
  end
end
