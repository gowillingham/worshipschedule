require 'spec_helper'

describe SkillshipsController do
  render_views
  
  before(:each) do
    @account = Factory(:account)
    @signed_in_user = Factory(:user, :email => Factory.next(:email))
    @accountship = @account.accountships.create(:user_id => @signed_in_user.id, :admin => true)
    
    @team = Factory(:team)
    @account.teams << @team
    @membership = @team.memberships.create(:user_id => @signed_in_user.id)
    
    signin_user @signed_in_user
    controller.set_session_account(@account)    
  end
  
  describe "POST 'create'" do
    
    before(:each) do
      
    end
  end
end