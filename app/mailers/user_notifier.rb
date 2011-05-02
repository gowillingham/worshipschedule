class UserNotifier < ActionMailer::Base
  default :from => "from@example.com"

  def forgot_password(user)
    @user = user

    mail :to => @user.email
    mail :subject => "[#{APP_NAME}] **Reset your password**"
  end
  
  def welcome_new_user(user, account, msg, added_by)
    @user = user
    @account = account
    @msg = msg
    @added_by = added_by
    
    mail :to => @user.email
    mail :subject => "[#{APP_NAME}] **Activate your account!**"
  end
  
  def welcome_existing_user(user, account, msg, added_by)
    @user = user
    @account = account
    @msg = msg
    @added_by = added_by
    
    mail :to => @user.email
    mail :subject => "[#{APP_NAME}] **You have been added to #{account.name}**"
  end
  
  def welcome_new_account(account, user)
    @account = account
    @user = user
    
    mail :to => @user.email
    mail :subject => "[#{APP_NAME}] **Info for your new account**"
  end
end
