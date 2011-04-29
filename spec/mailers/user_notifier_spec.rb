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
      @mail.body.encoded.should match('http://localhost:3000/profile/reset/')
    end
  end
end
