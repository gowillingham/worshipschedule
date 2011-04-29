class UserNotifier < ActionMailer::Base
  default :from => "from@example.com"

  def forgot_password(user)
    @user = user

    mail :to => @user.email
    mail :subject => "[#{APP_NAME}] **Reset your password**"
  end
end
