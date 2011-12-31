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
  
  describe "GET 'show'" do
    
    before(:each) do
      @skill = @team.skills.create(:name => 'Skill name', :description => 'This skill has a description')      
    end
    
    it "should allow an account admin" do
      get :show, :team_id => @team, :id => @skill
      
      response.should render_template('show')
    end
    
    it "should allow a team admin" do
      membership = @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      get :show, :team_id => @team, :id => @skill

      response.should render_template('show')
    end
    
    it "should allow a regular user" do
      @accountship.update_attribute(:admin, false)
      get :show, :team_id => @team, :id => @skill

      response.should render_template('show')
    end
    
    it "should redirect for a team from another account" do
      account = Factory(:account, :name => 'Orphan')
      team = account.teams.create(:name => 'Orphan')
      skill = team.skills.create(:name => 'Orphan')
      get :show, :team_id => team, :id => skill

      response.should redirect_to(@signed_in_user)
    end
    
    it "should redirect for a skill from another team" do
      account = Factory(:account, :name => 'Orphan')
      team = account.teams.create(:name => 'Orphan')
      skill = team.skills.create(:name => 'Orphan')
      get :show, :team_id => @team, :id => skill
      
      response.should redirect_to(@signed_in_user)
    end
    
    it "should show the details for the skill" do
      get :show, :team_id => @team, :id => @skill
      
      response.should have_selector('h3', :content => @skill.name)
      response.should have_selector('p', :content => @skill.description)
    end
    
    it "should have an edit link for the skill" do
      get :show, :team_id => @team, :id => @skill

      response.should have_selector('a', :content => 'Edit', :href => edit_team_skill_path(@team, @skill))
    end
    
    it "should list the members with the skill in the sidebar"    
    it "should show a link to edit the members with the skill"
    
    it "should not show admin features to regular users" do
      @accountship.update_attribute(:admin, false)
      get :show, :team_id => @team, :id => @skill

      response.should_not have_selector('a', :href => edit_team_path(@team))
      response.should_not have_selector('a', :href => edit_team_skill_path(@team, @skill))
    end
  end
  
  describe "PUT 'update'" do
    
      before(:each) do
        @skill = @team.skills.create(:name => 'Skill name')              
        @attr = {:name => 'New name', :description => 'New description' }
      end 
      
      it "should reject regular user" do 
        @accountship.update_attribute(:admin, false)
        put :update, :team_id => @team, :id => @skill, :skill => @attr
        
        response.should redirect_to(@signed_in_user)
      end
      
      it "should allow account admin" do
        put :update, :team_id => @team, :id => @skill, :skill => @attr
        
        response.should redirect_to(team_skills_path(@team))
      end
      
      it "should allow team admin" do
        membership = @team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
        @accountship.update_attribute(:admin, false)
        put :update, :team_id => @team, :id => @skill, :skill => @attr
        
        response.should redirect_to(team_skills_path(@team))
      end
      
      it "should not allow a team from another account" do
        account = Factory(:account, :name => 'Temp')
        team = account.teams.create(:name => 'temp')
        skill = team.skills.create(:name => 'temp')
        put :update, :team_id => team, :id => skill, :skill => @attr
        
        response.should redirect_to(@signed_in_user)
      end
      
      it "should not allow a skill from another team" do
        account = Factory(:account, :name => 'Temp')
        team = account.teams.create(:name => 'temp')
        skill = team.skills.create(:name => 'temp')
        put :update, :team_id => @team, :id => skill, :skill => @attr
        
        response.should redirect_to(@signed_in_user)        
      end
      
      it "should update the skill with valid attributes" do
        put :update, :team_id => @team, :id => @skill, :skill => @attr

        @attr[:name].should eq(Skill.find(@skill.id).name)
        @attr[:description].should eq(Skill.find(@skill.id).description)
      end
      
      it "should not update the skill if given invalid attributes" do
        put :update, :team_id => @team, :id => @skill, :skill => @attr.merge(:name => '')
        
        @skill.name.should eq(Skill.find(@skill.id).name)
        @skill.description.should eq(Skill.find(@skill.id).description)
      end
      
      it "should redisplay the page for invalid attributes" do
        put :update, :team_id => @team, :id => @skill, :skill => @attr.merge(:name => '', :description => '12345 ' * 100)
        
        response.should render_template('edit')
      end 
      
      it "should display error messages for invalid attributes" do
        put :update, :team_id => @team, :id => @skill, :skill => @attr.merge(:name => '', :description => '12345 ' * 100)
        
        response.should have_selector('div.error')
      end
  end 
  
  describe "GET 'edit'" do
    
    before(:each) do
      @skill = @team.skills.create(:name => 'Skill name')      
    end
    
    it "should not allow a regular user" do
      @accountship.update_attribute(:admin, false)
      get :edit, :team_id => @team, :id => @skill
      
      response.should redirect_to(@signed_in_user)      
    end 
    
    it "should allow an account admin" do
      get :edit, :team_id => @team, :id => @skill
      
      response.should render_template('edit')
    end

    it "should allow a team admin" do
      membership = @team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
      get :edit, :team_id => @team, :id => @skill
      
      response.should render_template('edit')
    end

    it "should not allow a team from a different account" do
      account = Factory(:account, :name => 'Temp')
      team = account.teams.create(:name => 'temp')
      skill = team.skills.create(:name => 'temp')
      get :edit, :team_id => team, :id => skill
      
      response.should redirect_to(@signed_in_user)
    end

    it "should not allow a skill from a different team" do
      account = Factory(:account, :name => 'Temp')
      team = account.teams.create(:name => 'temp')
      skill = team.skills.create(:name => 'temp')
      get :edit, :team_id => @team, :id => skill
      
      response.should redirect_to(@signed_in_user)
    end
    
    it "should display the form to edit the skill" do
      get :edit, :team_id => @team, :id => @skill
      
      response.should have_selector('input', :id => 'skill_name', :type => 'text', :value => @skill.name)
      response.should have_selector('input', :value => 'Save changes', :type => 'submit')
      response.should have_selector('a', :content => 'Cancel', :href => team_skills_path(@team))
    end
    
    it "should show a listing of members with the skill in the sidebar"
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @skill_1 = @team.skills.create(:name => 'Skill 1')
      @skill_2 = @team.skills.create(:name => 'Skill 2', :description => 'A short description for this skill. ')
      @skill_3 = @team.skills.create(:name => 'Skill 3', :description => 'A longer description for this skill. ' * 10)
    end
    
    it "should not allow a regular user" do
      @accountship.update_attribute(:admin, false)
      delete :destroy, :team_id => @team, :id => @skill_1
      
      response.should redirect_to(@signed_in_user)
    end
    
    it "should allow an account admin" do
      delete :destroy, :team_id => @team, :id => @skill_1
      
      response.should redirect_to(team_skills_path(@team))
    end
    
    it "should allow a team admin" do
      membership = @team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
      @accountship.admin = false
      @accountship.save
      delete :destroy, :team_id => @team, :id => @skill_1
      
      response.should redirect_to(team_skills_path(@team))
    end
    
    it "should not allow a team from a different account" do
      orphan_acct = Factory(:account, :name => 'orphan')
      team = orphan_acct.teams.create(:name => 'orphan team')
      skill = team.skills.create(:name => 'orphan skill')
      delete :destroy, :team_id => team, :id => skill
      
      response.should redirect_to(@signed_in_user)
    end
    
    it "should not allow a skill from a different team" do
      orphan_team = @account.teams.create(:name => 'Orphan team')
      orphan_skill = orphan_team.skills.create(:name => 'Orphan skill')
      delete :destroy, :team_id => @team, :id => orphan_skill
      
      response.should redirect_to(@signed_in_user)
    end
    
    it "should redirect to team#skills#index" do
      delete :destroy, :team_id => @team, :id => @skill_1

      response.should redirect_to(team_skills_path(@team))
    end
    
    it "should display flash comfirmation message" do
      delete :destroy, :team_id => @team, :id => @skill_1
      
      flash[:success].should =~ /was removed/i
    end
    
    it "should remove the skill" do
      lambda do
        delete :destroy, :team_id => @team, :id => @skill_1
      end.should change(Skill, :count).by(-1)
    end  
  end
  
  describe "GET 'index'" do
    
    before(:each) do
      @skill_1 = @team.skills.create(:name => 'Skill 1')
      @skill_2 = @team.skills.create(:name => 'Skill 2', :description => 'A short description for this skill. ')
      @skill_3 = @team.skills.create(:name => 'Skill 3', :description => 'A longer description for this skill. ' * 10)
    end
    
    it "should allow account admin" do
      get :index, :team_id => @team
      
      response.should render_template('index')
    end
    
    it "should allow team admin" do
      @accountship.update_attribute(:admin, false)
      @team.memberships.create(:user_id => @signed_in_user.id, :admin => true)
      
      get :index, :team_id => @team
      response.should render_template('index')
    end   
    
    it "should allow a regular team member" do
      @accountship.update_attribute(:admin, false)
      @team.memberships.create(:user_id => @signed_in_user.id, :admin => false)
      
      get :index, :team_id => @team
      response.should render_template('index')
    end
    
    it "should hide admin features from non-admin" do
      @accountship.update_attribute(:admin, false)
      @team.memberships.create(:user_id => @signed_in_user.id, :admin => false)
      get :index, :team_id => @team
      
      response.should_not have_selector('a', :content => 'New skill')
      response.should_not have_selector('a', :content => 'Team settings')
      response.should_not have_selector('.hover_menu')
    end 
    
    it "should show admin features to admin" do
      get :index, :team_id => @team
      
      response.should have_selector('a', :content => 'New skill')      
      response.should have_selector('a', :content => 'Team settings')
    end 
    
    it "should show all skills to admin" do
      get :index, :team_id => @team

      response.should have_selector('td', :content => @skill_1.name)
      response.should have_selector('td', :content => @skill_2.name)
      response.should have_selector('td', :content => @skill_3.name)
    end  
    
    it "should show remove/edit links to admin" do
      get :index, :team_id => @team

      response.should have_selector('td .hover_menu a', :content => 'Edit', :href => edit_team_skill_path(@team, @skill_1))
      response.should have_selector('td .hover_menu a', :content => 'Edit', :href => edit_team_skill_path(@team, @skill_2))
      response.should have_selector('td .hover_menu a', :content => 'Edit', :href => edit_team_skill_path(@team, @skill_3))
      response.should have_selector('td .hover_menu a', :content => 'Remove', :href => team_skill_path(@team, @skill_1))
      response.should have_selector('td .hover_menu a', :content => 'Remove', :href => team_skill_path(@team, @skill_2))
      response.should have_selector('td .hover_menu a', :content => 'Remove', :href => team_skill_path(@team, @skill_3))
    end
    
    it "should not allow team that belongs to another account" do
      rogue_acct = Factory(:account, :name => 'Orphan')
      team = rogue_acct.teams.create(:name => 'Orphan team')
      
      get :index, :team_id => team
      
      response.should_not render_template('index')
    end
    
    it "should show a blank slate to an admin when there are no skills" do
      @team.skills.clear
      get :index, :team_id => @team
      
      response.should have_selector('div.blank_slate')
      response.should have_selector('a', :content => 'Add the first skill', :href => new_team_skill_path(@team))
    end
    
    it "should indicate which skills (member-skills) belong to the current user with a check"
    it "should only show the skills (member-skills) for current_user if they are a regular user"
    it "should show blank slate to user who hasn't been assigned any skills"
    
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