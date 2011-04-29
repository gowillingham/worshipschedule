require "spec_helper"

describe UserNotifier do
  describe "forgot_password" do
    before(:each) do
      @user = Factory(:user)
      @mail = UserNotifier.forgot_password(user)
    end
  end
  
  it "it should send to the correct recipient"
  it "it should have the correct subject"
  it "it should have a reset link in the body"
end
