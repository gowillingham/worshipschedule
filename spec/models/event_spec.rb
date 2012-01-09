require 'spec_helper'

describe Event do
  
  before(:each) do
    @account = Factory(:account)
    @team = Factory(:team, :account_id => @account.id)
    @account.teams << @team
    
    @attr = {
      :team_id => @team.id,
      :name => 'New event',
      :description => 'the description',
      :start_at => '2012-02-01 7:30 pm',
      :end_at => '2012-02-01 9:30 pm',
      :all_day => false
    }
  end
  
  it "should create an instance" do
    Event.create!(@attr)
  end
  
  it "should require an name" do
    Event.new(@attr.merge(:name => '')).should_not be_valid
  end
  
  it "should not allow a name that is too long" do
    Event.new(@attr.merge(:name => "0123456789" * 11)).should_not be_valid
  end
  
  it "should not allow a description that is too long" do
    Event.new(@attr.merge(:description => "0123456789" * 51)).should_not be_valid
  end
  
  it "should require a start_at date and time" do
    Event.new(@attr.merge(:start_at => nil)).should_not be_valid
  end
  
  it "should require end_at after start_at" do
    Event.new(@attr.merge(:end_at => '2012-02-01 4:30 pm')).should_not be_valid
  end
  
  it "should create an event given valid attributes" do
    Event.new(@attr).should be_valid
  end
  it "should not create an event given invalid attributes"
  
  describe "method" do
    
    describe "team" do
      it "should exist"
      it "should return the team"
    end    
  end
end