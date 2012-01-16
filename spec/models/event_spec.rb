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
      :start_at_date => '2012-03-03',
      :start_at_time => '5:30 pm',
      :end_at_time => '6:30 pm',
      :end_at_date => '2012-03-04'
    }
  end
  
  it "should create an instance" do
    Event.create!(@attr)
  end
    
  it "given valid attributes it should be valid" do
    Event.new(@attr).should be_valid
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
  
  it "should require a start_at date" do
    Event.new(@attr.merge(:start_at_date => nil)).should_not be_valid
    Event.new(@attr.merge(:start_at_date => '')).should_not be_valid
  end
  
  it "should allow end_at_date to be nil" do
    Event.new(@attr.merge(:end_at_date => nil)).should be_valid
    Event.new(@attr.merge(:end_at_date => '')).should be_valid
  end
  
  it "should allow start_at_time to be nil" do
    Event.new(@attr.merge(:start_at_time => nil, :end_at_time => nil)).should be_valid
    Event.new(@attr.merge(:start_at_time => '', :end_at_time => nil)).should be_valid
  end
  
  it "should not allow end_at_time to be before start_at_time" do
    Event.new(@attr.merge(:start_at_date => '2012-03-03', :start_at_time => '5:30 pm', :end_at_date => '2012-03-03', :end_at_time => '4:30 pm')).should_not be_valid
  end
  
  it "should not accept an invalid date" do 
    Event.new(@attr.merge(:start_at_date => "2012-02-31")).should_not be_valid
    Event.new(@attr.merge(:end_at_date => "2012-02-31")).should_not be_valid
  end
  
  it "should require end_at_date on or after start_at_date" do
    Event.new(@attr.merge(:end_at_date => '2012-02-01')).should_not be_valid
  end
  
  it "should require a start_at_time if an end_at_time is provided" do
    Event.new(@attr.merge(:start_at_time => nil, :end_at_date =>nil, :end_at_time => '6:30 pm')).should_not be_valid
  end
  
  it "should create an event given valid attributes" do
    lambda do
      Event.create(@attr.merge(:end_at_date => nil, :end_at_time => nil))
    end.should change(Event, :count).by(1)
  end
  
  it "should not create an event given invalid attributes" do
    lambda do
      Event.create(@attr.merge(:start_at_date => '2012-02-31'))
    end.should change(Event, :count).by(0)
  end
  
  it "should set all_day to true if start_at_time is not provided" do
    event = Event.create(@attr.merge(:start_at_time => nil, :end_at_time => nil))
    Event.find(event.id).all_day.should be_true
  end
  
  it "should set all_day to false if start_at_time is provided" do
    event = Event.create(@attr.merge(:start_at_time => '5:30 pm', :end_at_time => nil, :end_at_date => nil))
    Event.find(event.id).all_day.should be_false
  end
  
  it "should set all_day to true if end_at_date is not equal to start_at_date" do
    event = Event.create(@attr.merge(:start_at_date => '2008-03-01', :end_at_date => '2008-03-03', :start_at_time => nil, :end_at_time => nil))
    Event.find(event.id).all_day.should be_true
  end
  
  it "should return times as nil if all_day is true" do
    event = Event.create(@attr.merge(:start_at_time => nil, :end_at_time => nil))
    Event.find(event.id).start_at_time.should be_nil
    Event.find(event.id).end_at_time.should be_nil
  end
  
  it "should return end_at_date and end_at_time as nil, and all_day as false if start_at_time only is provided" do
    event = Event.create(@attr.merge(:end_at_date =>nil, :end_at_time => nil))
    Event.find(event.id).end_at_date.should be_nil
    Event.find(event.id).end_at_time.should be_nil
    Event.find(event.id).all_day?.should be_false
  end
  
  it "should return end_at_date set to start_at_date and all_day? as false if start_at_time and end_at_time are provided" do
    event = Event.create(@attr.merge(:end_at_date =>nil, :end_at_time => '6:30 pm'))
    Event.find(event.id).end_at_date.should eq(Event.find(event.id).start_at_date)
    Event.find(event.id).all_day?.should be_false
    Event.find(event.id).end_at_time.strip!.should eq(@attr[:end_at_time])
    Event.find(event.id).start_at_time.strip!.should eq(@attr[:start_at_time])
  end

  describe "method" do
    
    before(:each) do
      @event = Event.create(@attr)
    end
    
    it "should respond to start_at_time" do
      @event.should respond_to(:start_at_time) 
    end 
    
    it "should respond to start_at_date" do
      @event.should respond_to(:start_at_date)
    end
    
    it "should respond to end_at_time" do
      @event.should respond_to(:end_at_time)
    end
    
    it "should respond to end_at_date" do
      @event.should respond_to(:end_at_date)
    end
    
    describe "team" do
      it "should exist" do
        @event.should respond_to(:team)
      end
      
      it "should return the team" do
        @event.team.should eq(@team)
      end
    end    
  end
end