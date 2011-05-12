require 'spec_helper'

describe TeamsController do
  render_views

  before(:each) do
    @signed_in_user = Factory(:user, :email => Factory.next(:email))
    @account = Factory(:account)
    @signed_in_user.accounts << @account
    
    signin_user @signed_in_user
    controller.set_session_account(@account)
  end
  
  describe "POST 'create'" do
    
    before(:each) do
      @attr = {
        :name => 'New name',
        :banner_text => 'banner text',
        :display_banner => false
      }
    end
    
    it "should redirect non-admin users" do
      post :create, :team => @attr
      response.should redirect_to(@signed_in_user)
    end
    
    describe "for admin" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should create a team given valid attributes" do
        lambda do
          post :create, :team => @attr
        end.should change(Team, :count).by(1)
      end
      
      it "should not create team given invalid attributes" do
        lambda do
          post :create, :team => @attr.merge(:name => '')
        end.should change(Team, :count).by(0)
      end
      
      it "should redirect to teams#show with flash for the new team" do
        post :create, :team => @attr
        response.should redirect_to(team_path(assigns(:team)))
        flash[:success] =~ /successfully saved/i
      end
    end
  end
  
  describe "GET 'new'" do

    it "should redirect non-admin users" do
      get :new
      response.should redirect_to(@signed_in_user)
    end
    
    it "should allow admin users" do
      accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
      accountship.admin = true
      accountship.save
      
      get :new
      response.should render_template('new')
    end
  end
  
  describe "PUT 'update'" do
    
    before(:each) do
      @team = @account.teams[0]
      @attr = {
        :name => 'New name',
        :banner_text => 'banner text',
        :display_banner => false
      }
    end
    
    it "should only allow authenticated access" do
      controller.sign_out
      put :update, :id => @team, :team => @attr
      response.should redirect_to(signin_path)
    end
    
    it "should only allow admin access" do
      put :update, :id => @team, :team => @attr
      response.should redirect_to(user_path(@signed_in_user))
    end
    
    describe "for admin users" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should allow access" do
        put :update, :id => @team, :team => @attr
        response.should be_success
      end
      
      it "should require a name" do
        put :update, :id => @team, :team => @attr.merge(:name => '')
        response.should render_template('edit')
        response.should have_selector("div#error_explanation")
      end
      
      it "should update the team given valid attributes" do
        put :update, :id => @team, :team => @attr
        @attr[:name].should eq(Team.find(@team.id).name)
        @attr[:banner_text].should eq(Team.find(@team.id).banner_text)
        @attr[:display_banner].should eq(Team.find(@team.id).display_banner)
      end
      
      it "should not update the team given invalid attributes" do
        put :update, :id => @team, :team => @attr.merge(:name => '', :banner_text => 'different banner text')
        @team.name.should eq(Team.find(@team.id).name)
        @team.banner_text.should eq(Team.find(@team.id).banner_text)
      end
      
      it "should render edit with flash message on success" do
        put :update, :id => @team, :team => @attr
        response.should render_template('edit')
        flash[:success].should =~ /settings have been updated/i
      end
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @team = @account.teams[0]
    end
    
    it "should only allow authenticated access" do
      controller.sign_out
      get :edit, :id => @team
      response.should redirect_to(signin_path)
    end
        
    describe "for admin users" do
      
      before(:each) do
        accountship = @signed_in_user.accountships.where('account_id = ?', @account.id).first
        accountship.admin = true
        accountship.save
      end
      
      it "should allow access" do
        get :edit, :id => @team
        response.should render_template('edit')
      end
      
      it "should have the team name and account name in the header" do
        get :edit, :id => @team
        response.should have_selector('h1', :content => @account.teams[0].name)
        response.should have_selector('span', :content => @account.name)
      end
      
      it "should show a delete link in the sidebar" do
        get :edit, :id => @team
        response.should have_selector('a', :href => team_path(@team))
        response.should have_selector('a', :content => "Yes, I understand - delete this team")
      end
    end
    
    describe "for non-admin users" do
      
      it "should deny access" do
        get :edit, :id => @account.teams[0]
        response.should redirect_to(@signed_in_user)
      end
    end
    
  end
    
  describe "GET 'show'" do
    
    it "should be successful" do
      get :show, :id => @account.teams[0]
      response.should be_success
    end
    
    it "should only allow authenticated access" do
      controller.sign_out
      get :show, :id => @account.teams[0]
      response.should redirect_to(signin_path)
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
    
    it "should display team.banner_text" do
      get :show, :id => @account.teams[0]

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
      
      it "should not display the team settings link" do
        get :show, :id => @account.teams[0]
        response.should_not have_selector('a', :content => 'Team settings')
      end
      
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
