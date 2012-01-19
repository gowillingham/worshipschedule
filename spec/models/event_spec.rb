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
  
  it "should call the event 'untitled event' if no name is provided" do
    event = Event.create(@attr.merge(:name => nil))
    
    event.name =~ /untitled event/i
  end
  
  it "should not require an name" do
    Event.new(@attr.merge(:name => '')).should be_valid
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
      Event.create(@attr.merge(:start_at_date => 'not a date'))
    end.should change(Event, :count).by(0)
  end
  
  it "should return expected attributes when no times or end_at_date are provided" do
    event = Event.create(@attr.merge(:end_at_date => nil, :end_at_time => nil, :start_at_time => nil))
    event.reload.all_day.should be_true
    event.reload.start_at_date.should eq(@attr[:start_at_date])
    event.reload.start_at_time.should be_nil
    event.reload.end_at_date.should be_nil
    event.reload.end_at_time.should be_nil    
  end 
  
  it "should return expected attributes when start date and start time are provided without end time" do
    event = Event.create(@attr.merge(:end_at_date => nil, :end_at_time => nil))
    event.reload.all_day.should be_false
    event.reload.start_at_date.should eq(@attr[:start_at_date])
    event.reload.start_at_time.should eq(@attr[:start_at_time])
    event.reload.end_at_date.should be_nil
    event.reload.end_at_time.should be_nil
  end
  
  it "should return expected attributes when start date, start time, and end time are provided without end date" do
    event = Event.create(@attr.merge(:end_at_date => nil))
    event.reload.all_day.should be_false
    event.reload.start_at_date.should eq(@attr[:start_at_date])
    event.reload.start_at_time.should eq(@attr[:start_at_time])
    event.reload.end_at_date.should be_nil
    event.reload.end_at_time.should eq(@attr[:end_at_time])   
  end 
  
  it "should return expected attributes when start date and end date are provided without times" do
    event = Event.create(@attr.merge(:start_at_time => nil, :end_at_time => nil))
    event.reload.all_day.should be_true
    event.reload.start_at_date.should eq(@attr[:start_at_date])
    event.reload.start_at_time.should be_nil
    event.reload.end_at_date.should eq(@attr[:end_at_date])
    event.reload.end_at_time.should be_nil 
  end 
  
  it "should return expected attributes on save" do
    event = Event.create(@attr.merge(:end_at_date => nil))
    event.reload.all_day.should be_false
    event.reload.start_at_date.should eq(@attr[:start_at_date])
    event.reload.start_at_time.should eq(@attr[:start_at_time])
    event.reload.end_at_date.should be_nil
    event.reload.end_at_time.should eq(@attr[:end_at_time])   
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