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
        response.should render_template('forgot')
      end
      
      it "should redisplay the forgot screen with a flash message" do
        put :send_reset, :user => @attr
        response.should render_template('forgot')
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
      end
      
      it "should update user's password reset fields" do
        user = User.find_by_email(@user.email)
        user.reset_password_token_created_at.should_not be_nil
        user.reset_password_token.should_not be_nil
        user.reset_password_complete.should_not be_true
      end
      
      it "should email the password reset token to the user"
    end
  end
end
  
  