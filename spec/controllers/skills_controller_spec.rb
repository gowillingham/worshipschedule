require 'spec_helper'

describe SkillsController do
  render_views
  
  before(:each) do
    @signed_in_user = Factory(:user)
    @account = Factory(:account)
    @accountship = @account.accountships.create(:user_id =>@signed_in_user, :admin => true)

    signin_user @signed_in_user
    controller.set_session_account(@account)
    
    @team = Factory(:team, :account_id => @account.id)
  end
  
  describe "for a team or account admin user" do
    it "should not allow a skill from a different team"
  end
  
  describe "POST 'create'" do
    
    before(:each) do
      @attr = {
        :name => "Attr team",
        :description => "The description for the team"
      }
    end
    
    it "should redirect for non-team admin or non-account admin" do
      team = @account.teams.create(:name => 'Orphan team')
      team.memberships.create(:team_id => team.id, :admin => false)
      @accountship.update_attribute(:admin, false)
      
      post :create, :team_id => team, :skill => @attr
      response.should redirect_to(@signed_in_user)
    end
    
    it "should redirect for a team that doesn't belong to the current account" do
      other_account = Account.create(:name => 'Name')
      other_team = other_account.teams.create(:name => 'Team')
      
      post :create, :team_id => other_team, :skill => @attr
      response.should_not render_template('new')
    end
    
    it "should create a skill given valid attributes" do      
      lambda do
        post :create, :team_id => @team, :skill => @attr        
      end.should change(Skill, :count).by(1)
    end
    
    it "should display flash success message" do
      post :create, :team_id => @team, :skill => @attr
      flash[:success].should =~ /successfully saved/i
    end
    
    it "should redisplay the new page with invalid attributes" do
        post :create, :team_id => @team, :skill => @attr.merge(:name => '', :description => ("12345" * 101))      
        
        response.should render_template('new')
    end
    
    it "should require a name" do
      lambda do
        post :create, :team_id => @team, :skill => @attr.merge(:name => '')
      end.should change(Skill, :count).by(0)
    end
    
    it "should not allow description that is too long" do
      lambda do
        post :create, :team_id => @team, :skill => @attr.merge(:description => '12345' * 101)
      end.should change(Skill, :count).by(0)
    end
    
    it "should redirect to skill#index on success" do
      post :create, :team_id => @team, :skill => @attr
      
      response.should redirect_to(team_skills_path(@team))
    end
  end
  
  describe "GET 'new'" do
    
    it "should allow admin user" do
      get :new, :team_id => @team
      response.should render_template('new')
    end 
    
    it "should allow team admin who is not account admin" do
      @accountship.admin = false
      @account.save
      @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      
      get :new, :team_id => @team
      response.should render_template('new')
    end 
    
    it "should not allow a team that doesn't belong to the current account" do
      another_account = Factory(:account)
      another_team = Factory(:team, :account_id => another_account.id)
      get :new, :team_id => another_team
      
      response.should_not render_template('new')
    end
  end
end