module SessionsHelper
  require 'digest/sha1'
  
  def authenticate
    if signed_in?
      check_session
    else
      boot_session
    end
  end
  
  def redirect_to_landing_page_for(user)
    if user.accounts.size == 1
      account = user.accounts.find :first
      set_session_account account
      redirect_to user
    else
      @context = 'accounts'
      redirect_to sessions_accounts_path
    end
  end
  
  def require_account_admin
    unless (admin? || owner?)
      flash[:error] = "You must be an administrator for #{current_account.name} to access that page. "
      redirect_to current_user
    end
  end
  
  def check_account
    unless account_set?
      flash[:error] = "You'll need to select one of your churches before you can access that page. "
      redirect_to(sessions_accounts_path)
    end
  end
  
  def check_session
    if (Time.now.utc - session[:starts]) > LOGIN_SESSION_LENGTH
      boot_session
    else
      refresh_session
    end
  end
  
  def admin?
    unless current_account.nil?
      
      accountship = current_user.accountships.where('account_id = ?', current_account.id).first
      unless accountship.nil?
        accountship.admin?
      else
        false
      end
      
    else
      false
    end
  end
  
  def owner?
    current_user == current_account.owner
  end
  
  def boot_session
    sign_out
    flash[:error] = "Can't show you that page until you sign in!"
    redirect_to signin_path
  end
  
  def set_session_account(account)
    session[:account_id] = account.id
    refresh_session
    self.current_account = account
  end
  
  def sign_in(user)
    session[:user_id] = user.id
    refresh_session
    self.current_user = user
  end
  
  def refresh_session
    session[:starts] = Time.now.utc
  end
  
  def reset_forgot_hash_with_timeout_for(user)
    user.forgot_hash_created_at = Time.now
    user.forgot_hash = Digest::SHA1.hexdigest "#{user.encrypted_password}--#{user.id}"
    user.save
  end
  
  def reset_forgot_hash_for(user)
    user.forgot_hash_created_at = nil
    user.forgot_hash = Digest::SHA1.hexdigest "#{user.encrypted_password}--#{user.id}"
    user.save
  end
  
  def signed_in? 
    !current_user.nil?
  end
  
  def account_set?
    !current_account.nil?
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
