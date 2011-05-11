require 'spec_helper'

describe TeamsController do
  render_views

  describe "GET 'show'" do
    
    before(:each) do
      @signed_in_user = Factory(:user, :email => Factory.next(:email))
      @account = Factory(:account)
      @signed_in_user.accounts << @account
      
      signin_user @signed_in_user
      controller.set_session_account(@account)
    end
    
    it "should be successful" do
      get :show, :id => @account.teams[0]
      response.should be_success
    end
    
    it "should have a back to dashboard link" do
      get :show, :id => @account.teams[0]
      response.should have_selector("a", :href => user_path(@signed_in_user.id))
    end
    
    it "should have the team name and account name in the header" do
      get :show, :id => @account.teams[0]
      response.should have_selector('h1', :content => @account.teams[0].name)
      response.should have_selector('span', :content => @account.name)
    end
    
    describe "for admin users" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should show the correct tabs" do
        get :show, :id => @account.teams[0]
        response.should have_selector('ul.tabs li a', :content => 'Overview')
        response.should have_selector('ul.tabs li a', :content => 'Skills')
        response.should have_selector('ul.tabs li a', :content => 'Events')
        response.should have_selector('ul.tabs li a', :content => 'Files')
        response.should have_selector('ul.tabs li a', :content => 'People and permissions')
        response.should have_selector('ul.tabs li a', :content => 'Email')
      end
      
      it "should show a link to team settings" do
        get :show, :id => @account.teams[0]
        response.should have_selector('a', :content => 'Team settings')
      end
      
      it "should show the new toolbar"
    end
    
    describe "for non-admin users" do
      
      it "should show the correct tabs" do
        get :show, :id => @account.teams[0]

        response.should have_selector('ul.tabs li a', :content => 'Overview')
        response.should_not have_selector('ul.tabs li a', :content => 'Skills')
        response.should have_selector('ul.tabs li a', :content => 'Events')
        response.should have_selector('ul.tabs li a', :content => 'Files')
        response.should_not have_selector('ul.tabs li a', :content => 'People and permissions')
        response.should_not have_selector('ul.tabs li a', :content => 'Email')
      end
    end
    
  end

end
