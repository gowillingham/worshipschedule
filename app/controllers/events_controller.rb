class EventsController < ApplicationController
  before_filter(:except => [:show, :index]) { require_account_or_team_admin(params[:team_id]) }
  before_filter { require_team_for_current_account(params[:team_id]) }
  before_filter(:except => [:new, :create, :index]) { require_event_for_current_team(params[:team_id], params[:id])}
  before_filter { require_team_member(params[:team_id]) }
  
  def show
    @team = Team.find(params[:team_id])
    @event = Event.find(params[:id])
    
    @sidebar_partial = 'events/sidebar/show'
    @title = 'Event details'
    render 'show'
  end
  
  def destroy
    @event = Event.find(params[:id])
    @event.delete
    redirect_to team_events_url(params[:team_id]), :flash => { :success => 'Your event was removed'}
  end
  
  def update
    @team = Team.find(params[:team_id])
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash[:success] = "The changes to the event were saved"
      redirect_to(team_events_url(@team))
    else
      @sidebar_partial = 'users/sidebar/placeholder'
      render 'edit'
    end    
  end
  
  def edit
    @team = Team.find(params[:team_id])
    @event = Event.find(params[:id])
    @title = 'Edit event'
    @sidebar_partial = 'events/sidebar/edit'
  end 
  
  def index
    @team = Team.find(params[:team_id])
    @events = @team.events
    @events.sort! { |a,b| b.start_at <=> a.start_at}
    @title = 'All events'
    @sidebar_partial = 'users/sidebar/placeholder'
  end
  
  def create 
    @team = Team.find(params[:team_id])
    @event = @team.events.new(params[:event])
    if @event.save
      flash[:success] = 'The new event was successfully saved '
      redirect_to(team_events_url(@team))
    else
      @sidebar_partial = 'users/sidebar/placeholder'
      render 'new'
    end
  end
  
  def new
    @team = Team.find(params[:team_id])
    @event = @team.events.new(:start_at_date => Date.today.to_s)
    @title = "New event"
    @sidebar_partial = 'users/sidebar/placeholder'
  end
  
  private
  
    def require_event_for_current_team(team_id, event_id)
      team = Team.find(team_id)
      event = Event.find(event_id)
      unless team.events.include?(event)
        redirect_to current_user, :flash => { :error => "You don't have permission to modify that event" }        
      end
    end

end