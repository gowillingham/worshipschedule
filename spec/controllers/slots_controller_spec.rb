require 'spec_helper'

describe SlotsController do
  render_views
  
  before(:each) do
    @signed_in_user = Factory(:user, :email => Factory.next(:email))
    @account = Factory(:account)
    @accountship = @account.accountships.create(:user_id => @signed_in_user.id, :admin => true)
    
    signin_user @signed_in_user
    controller.set_session_account(@account)
  end
  
  describe "POST 'create'" do
    
  end
end
