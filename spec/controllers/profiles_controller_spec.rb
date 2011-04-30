require 'spec_helper'

describe ProfilesController do
  render_views
  
  before(:each) do
    @user = Factory(:user, :password => 'password', :password_confirmation => 'password')
    
    @signed_in_user = Factory(:user, :email => Factory.next(:email))
    @account = Factory(:account)
    @signed_in_user.accounts << @account
    
    @accountship = @signed_in_user.accountships.find_by_account_id(@account.id)
    @accountship.admin = true
    @accountship.save
    
    signin_user @signed_in_user
    controller.set_session_account(@account)
  end

  describe "GET 'edit'" do
    
    it "should be success" do
      get :edit
      response.should be_success
    end
    
    it "should require signed in user" do
      controller.sign_out
      get :edit
      response.should redirect_to(signin_path)
    end
    
    it "should allow non-admin user" do
      @accountship.admin = false
      @accountship.save
      
      get :edit
      response.should render_template('edit')
    end
    
    it "should have a link to change the avatar" do
      get :edit
      response.should have_selector("a", :content => 'Change my Gravatar image')
    end
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      @attr = {
        :password => 'password',
        :password_confirmation => 'password'
      }
    end
    
    it "should require signed in user" do
      controller.sign_out
      put :update, :user => @attr
      response.should redirect_to(signin_path)
    end
    
    it "should allow non-admin user"  do
      @accountship.admin = false
      @accountship.save
      
      put :update, :user => @attr
      response.should redirect_to(edit_profile_path)
    end
    
    it "should require password confirmation" do
      put :update, :user => @attr.merge(:password_confirmation => 'invalid')
      response.should render_template('edit')
      response.should have_selector('div#error_explanation')      
    end
    
    it "should not allow a blank password" do
      put :update, :user => @attr.merge(:password => '', :password_confirmation => '')
      response.should render_template('edit')
      response.should have_selector('div#error_explanation')      
    end
    
    it "should redirect with flash message on success" do
      put :update, :user => @attr
      response.should redirect_to(edit_profile_path)
      flash[:success] =~ /password was changed/i
    end
  end
  
  describe "GET 'forgot'" do
    
    it "should not require a signed in user" do
      controller.sign_out
      get :forgot
      response.should render_template('forgot')
    end
    
    it "should have a link to return to the signin screen" do
      get :forgot
      response.should have_selector('a', :content => 'send me back to the sign in screen')
    end
  end
  
  describe "PUT 'reset'" do
    
    before(:each) do
      controller.refresh_forgot_hash_with_timeout @user
    end
    
    it "should display the password edit screen" do
      put :reset, :token => @user.forgot_hash
      response.should render_template('reset')
    end
    
    it "should display the expired screen after the timeout interval" do
      @user.forgot_hash_created_at = (@user.forgot_hash_created_at - RESET_PASSWORD_TOKEN_TIMEOUT - 1.minute)
      @user.save
      
      put :reset, :token => @user.forgot_hash
      response.should render_template('expired')
    end
end
  
  describe "PUT 'send_reset'" do
    
    describe "for a user email not found" do
      
      before(:each) do
        @attr = {
          :email => 'this_user@wont_be_found.com'
        }
      end
      
      it "should not require a signed in user" do
        controller.sign_out
        put :send_reset, :user => @attr
        response.should redirect_to(forgot_profile_url)
      end
      
      it "should redisplay the forgot screen with a flash message" do
        put :send_reset, :user => @attr
        response.should redirect_to(forgot_profile_url)
        flash[:error].should =~ /couldn't find anyone/i
      end
    end
    
    describe "for a found user email" do
      
      before(:each) do
        @user = Factory(:user, :email => Factory.next(:email))
        @attr = {:email => @user.email}
      end
      
      it "should not require a signed in user" do
        controller.sign_out
        put :send_reset, :user => @attr
        response.should redirect_to(signin_path)
      end
      
      it "should display the signin page with flash confirmation" do
        put :send_reset, :user => @attr
        response.should redirect_to(signin_path)
        flash[:success] =~ /have been emailed/i
      end
      
      it "should update user's password reset fields" do
        put :send_reset, :user => @attr
        
        user = User.find(:first, :conditions => [ "lower(email) = ?", @user.email.downcase ])
        user.forgot_hash.should_not be_nil
        user.forgot_hash_created_at.should_not be_nil
      end
      
      it "should email the password reset token to the user"
    end
  end
  
  describe "PUT 'update_reset" do
    
    describe "with invalid password/password_confirmation" do
      
      before(:each) do
        @user = Factory(:user)
        @attr = {
          :password => 'password',
          :password_confirmation => 'invalid'
        }
      end
      
      it "should not change the password" do
        original_hash = @user.encrypted_password
        
        put :update_reset, :id => @user, :user => @attr
        user = User.find(@user)
        user.encrypted_password.should == original_hash
      end
      
      it "should redisplay the reset password form with error messages" do
        put :update_reset, :id => @user, :user => @attr
        response.should render_template('reset')
      end
    end
    
    describe "with valid password/password_confirmation" do
      
      before(:each) do
        @user = Factory(:user)
        @attr = {
          :password => 'new password',
          :password_confirmation => 'new password'
        }
      end
      
      it "should change the password" do
        original_hash = @user.encrypted_password
        
        put :update_reset, :id => @user, :user => @attr
        user = User.find(@user)
        user.encrypted_password.should_not == original_hash
      end
      
      it "should redirect to user#show (since only one account defined for user above)" do
        put :update_reset, :id => @user, :user => @attr
        response.should redirect_to(@user)
      end
      
      it "should signin the user" do
        put :update_reset, :id => @user, :user => @attr
        @user.id.should == @request.session[:user_id]
        @user.id.should == controller.current_user.id
        controller.should be_signed_in
      end
    end
  end
end
  
  