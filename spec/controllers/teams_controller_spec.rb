require 'spec_helper'

describe TeamsController do

  describe "GET 'show'" do
    
    it "should be successful" do
      get 'show'
      response.should be_success
    end
    
    it "should show the correct tabs to regular users"
    it "should show the correct tabs to administrators"
    it "should show the new toolbar to administrators"
    it "should have a back to dashboard link"
    it "should have the team name and account name in the header"
    it "should have a team settings link in the header"
  end

end
