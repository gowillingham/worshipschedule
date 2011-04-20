require 'spec_helper'

describe "LayoutTemplates" do

  it "should have a home page at '/'" do
    get '/'
    response.should have_selector('title', :content => 'home')
  end
  
  it "should have a signin page at '/signin'" do
    get '/signin'
    response.should have_selector('title', :content => 'sign in')
  end
  
  describe "when not signed in" do
    
    it "should have a sign in link" do
      get root_path
      response.should have_selector('a', :content => 'sign in', :href => signin_path)
    end
    
    it "should allow access to home page" do
      get root_path
      response.should have_selector('title', :content => 'home')
    end
    
    it "should allow access to signin page" do
      get signin_path
      response.should have_selector('title', :content => 'sign in')
    end

    it "should prevent access to protected pages" do
      get new_user_path
      response.should redirect_to(signin_path)
    end
  end
  
  describe "when signed in" do
    
    before(:each) do
      @user = Factory(:user)
      @account = Factory(:account)
      @accountship = @user.accountships.create(:account_id => @account.id, :admin => true)
      visit signin_path
      fill_in :email, :with => @user.email
      fill_in :password, :with => @user.password
      click_button
    end
    
    it "should have a sign out link" do
      get root_path
      response.should have_selector('a', :content => 'sign out', :href => signout_path)
    end
    
    describe "as admin" do
      
      it "should show the admin tabstrip" do
        get user_path(@user.id)
        response.should have_selector('ul', :class => 'tabs')
      end
    end
    
    describe "as regular user" do
      
      it "should not show the admin tabstrip" do
        @accountship.admin = false
        @accountship.save
        get user_path(@user.id)
        response.should_not have_selector('ul', :class => 'tabs admin')
      end
    end
  end
end
