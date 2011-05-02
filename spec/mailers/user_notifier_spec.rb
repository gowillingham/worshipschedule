require "spec_helper"

describe UserNotifier do
  
  describe "forgot_password" do
    
    before(:each) do
      @user = Factory(:user)
      @user.forgot_hash = 'hash'
      @user.save
      @mail = UserNotifier.forgot_password(@user)
    end
  
    it "it should send to the correct recipient" do
      @mail.to.should == [@user.email]
    end
    
    it "it should have the correct subject" do
      @mail.subject.should =~ /reset/i
      @mail.subject.should =~ /password/i
    end
    
    it "it should have a reset link in the body" do
      @mail.body.encoded.should match('http://localhost:3000/profile/reset/hash')
    end
  end
  
  describe "welcome_new_user" do
    
    before(:each) do
      @user = Factory(:user)
      @user.forgot_hash = 'hash'
      @user.save
      @account = Factory(:account)
      @user.accounts << @account
      @added_by = Factory(:user, :first_name => 'Bruce', :last_name => 'Springsteen', :email => Factory.next(:email))
      @msg = "This is a link to the scheduling program we talked about. Just click the link above to create create your password. "
      @mail = UserNotifier.welcome_new_user @user, @account, @msg, @added_by
    end
    
    it "should send to the correct recipient" do
      @mail.to.should == [@user.email]
    end
    
    it "should have the correct subject" do
      @mail.subject.should =~ /activate/i
    end
    
    it "should include the message from the person adding the user" do
      @mail.body.encoded.should match(@msg)
    end
    
    it "should have a reset link in the body" do
      @mail.body.encoded.should match(profile_reset_url(@user.forgot_hash))
      @mail.body.encoded.should have_selector("a", :content => profile_reset_url(@user.forgot_hash))
    end
    
    it "should have the added by name or email in the body" do
      @mail.body.encoded.should match(@added_by.name_or_email)
    end
  end
  
  describe "welcome_existing_user" do
    before(:each) do
      @user = Factory(:user)
      @user.forgot_hash = 'hash'
      @user.save
      @account = Factory(:account)
      @added_by = Factory(:user, :first_name => 'Bruce', :last_name => 'Springsteen', :email => Factory.next(:email))
      @msg = "This is a link to the scheduling program we talked about. Just click the link above to create create your password. "
      @mail = UserNotifier.welcome_existing_user @user, @account, @msg, @added_by
    end

    it "should send to the correct recipient" do
      @mail.to.should == [@user.email]
    end
    
    it "should include the message from the person adding the user" do
      @mail.body.encoded.should match(@msg)
    end
    
    it "should have the correct subject" do
      @mail.subject.should =~ /added/i
      @mail.subject.should match(@account.name)
    end
    
    it "should have a signin link in the body" do
      @mail.body.encoded.should have_selector("a", :content => signin_url)
      @mail.body.encoded.should match(signin_url)
    end
    
    it "should have the added by name or email in the body" do
      @mail.body.encoded.should match(@added_by.name_or_email)
    end
  end
  
  describe "welcome_new_account" do
    
    before(:each) do
      @user = Factory(:user, :forgot_hash => 'hash')
      @account = Factory(:account)
      @mail = UserNotifier.welcome_new_account @account, @user
    end
    
    it "should have the correct subject" do
      @mail.subject.should =~ /new account/i
    end
    
    it "should send to the correct recipient" do
      @mail.to.should == [@user.email]
    end
    
    it "should include a link to reset a password" do
      @mail.body.encoded.should have_selector("a", :content => profile_reset_url(@user.forgot_hash))
      @mail.body.encoded.should match(profile_reset_url(@user.forgot_hash))
    end
    
    it "should include a link to signin" do
      @mail.body.encoded.should have_selector("a", :content => signin_url)
      @mail.body.encoded.should match(signin_url)
    end
    
    it "should include a link to email support" do
      @mail.body.encoded.should have_selector("a", :content => SUPPORT_EMAIL)
      @mail.body.encoded.should match("mailto:#{SUPPORT_EMAIL}")
    end
  end
end
