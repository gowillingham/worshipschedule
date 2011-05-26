require 'spec_helper'

describe MembershipsController do
  render_views
  
  before(:each) do
    @account = Factory(:account)
    @team = @account.teams[0]
    @signed_in_user = Factory(:user)
    @accountship = Accountship.create(
      :user_id => @signed_in_user.id,
      :account_id => @account.id,
      :admin => true
    )
    @membership = Membership.create(
      :user_id => @signed_in_user.id,
      :team_id => @team.id,
      :admin => false
    )
    signin_user @signed_in_user
    controller.set_session_account(@account)
    
    @second_user = Factory(:user, :email => Factory.next(:email))
    @third_user = Factory(:user, :email => Factory.next(:email))
    @new_user = Factory(:user, :email => Factory.next(:email))
    
    @account.users << @second_user
    @account.users << @third_user
    
    @team.users << @second_user
    @team.users << @third_user
  end
  
  describe "POST 'create'" do
    
    it "should not allow unauthenticated access" do
      controller.sign_out
      post :create, :team_id => @team.id, :user_id => @new_user.id
      
      response.should redirect_to(signin_path)
    end
    
    describe "for admin" do
      
      before(:each) do
        @membership = @signed_in_user.memberships.where(:team_id => @team.id).first
        @membership.update_attributes(:admin => true)
      end
      
      before(:each) do
        @account.users << @new_user
      end
      
      it "should allow account admin" do
        @membership.update_attributes(:admin => false)
        
        post :create, :team_id => @team.id, :user_id => @new_user.id
        response.should be_success
      end
      
      it "should allow team admin" do
        @accountship.update_attributes(:admin => false)
        
        post :create, :team_id => @team.id, :user_id => @new_user.id
        response.should be_success
      end
      
      it "should not allow non-admin" do
        @membership.update_attributes(:admin => false)
        @accountship.update_attributes(:admin => false)
        
        post :create, :team_id => @team.id, :user_id => @new_user.id
        response.should redirect_to(@signed_in_user)
      end
      
      it "it should create a membership given valid attributes" do
        lambda do
          post :create, :team_id => @team.id, :user_id => @new_user.id
        end.should change(Membership, :count).by(1)        
      end
      
      it "it should not create a membership for a non-account user" do
        @new_user.accounts.clear
        
        lambda do
          post :create, :team_id => @team.id, :user_id => @new_user.id
        end.should change(Membership, :count).by(0)
      end
    end
  end
  
  describe "GET 'index'" do
    
    it "should redirect for non-authenticated users" do
      controller.sign_out
      get :index, :team_id => @team
      response.should redirect_to(signin_path)      
    end
    
    it "should allow account admin" do
      @membership.admin = false
      @membership.save
      
      get :index, :team_id => @team
      response.should render_template('index')
    end
    
    it "should allow a team admin" do
      @accountship.admin = false
      @accountship.save
      @membership.admin = true
      @membership.save
      
      get :index, :team_id => @team
      response.should render_template('index')
    end
    
    it "should redirect team member who is not team or account admin" do
      @accountship.admin = false
      @accountship.save
      @membership.admin = false
      @membership.save
      
      get :index, :team_id => @team
      response.should redirect_to(@signed_in_user)
      flash[:error] =~ /don't have permission/i      
    end
    
    it "should have a link to add/remove users" do
      get :index, :team_id => @team
      response.should have_selector("a", :content => 'Add people, remove people, change permissions')
    end
    
    it "should display the team members" do
      get :index, :team_id => @team
      response.should have_selector("a", :content => @second_user.email)
      response.should have_selector("a", :content => @third_user.email)
      response.should have_selector("a", :content => @signed_in_user.email)
    end
    
    it "should display account admin badge" do
      get :index, :team_id => @team
      response.should have_selector("div", :class => 'admin')
    end
    
    it "should display team admin badge" do
      @accountship.admin = false
      @accountship.save
      @membership.admin = true
      @membership.save
      
      get :index, :team_id => @team
      response.should have_selector("div", :class => 'team_admin')
    end
    
    it "should display blank slate for no team members" do
      @team.memberships.clear
      
      get :index, :team_id => @team
      response.should have_selector("h2", :content => "Let's add the first member to this team.")
    end
  end
end
