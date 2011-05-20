require 'spec_helper'

describe MembershipsController do
  render_views
  
  before(:each) do
    @account = Factory(:account)
    @team = Factory(:team, :account_id => @account.id)
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
    
    @account.users << @second_user
    @account.users << @third_user
    
    @team.users << @second_user
    @team.users << @third_user
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
    
    it "should display account admin badge"
    it "should display team admin badge"
    it "should display blank slate for no team members"
  end
end
