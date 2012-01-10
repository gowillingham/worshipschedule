require 'spec_helper'

describe EventsController do
  render_views

  before(:each) do
    @signed_in_user = Factory(:user)
    @account = Factory(:account)
    @accountship = @account.accountships.create(:user_id =>@signed_in_user, :admin => true)

    signin_user @signed_in_user
    controller.set_session_account(@account)
    
    @team = Factory(:team, :account_id => @account.id)
  end
  
  describe "GET 'new'" do
    
    before (:each) do
      
    end
    
    it "should allow an account admin" do
      get :new, :team_id => @team
      
      response.should render_template('new')
    end
    
    it "should allow a team admin who is not account admin" do
      @team.memberships.create(:user_id => @signed_in_user, :admin => true)
      @accountship.update_attribute(:admin, false)
      get :new, :team_id => @team
      
      response.should render_template('new')
    end
    
    it "should redirect a regular user" do
      @accountship.update_attribute(:admin, false)
      get :new, :team_id => @team
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
    
    it "should redirect for a team that is not from the current_account" do
      account = Factory(:account)
      team = Factory(:team, :account_id => account.id)
      get :new, :team_id => team
      
      response.should redirect_to(@signed_in_user)
      flash[:error].should =~ /don't have permission/i
    end
  end
end