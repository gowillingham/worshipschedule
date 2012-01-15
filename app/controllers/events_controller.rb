class EventsController < ApplicationController
  before_filter(:except => [:show, :index]) { require_account_or_team_admin(params[:team_id]) }
  before_filter { require_team_for_current_account(params[:team_id]) }
  before_filter { require_team_member(params[:team_id]) }
  
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
      redirect_to(team_events_path(@team))
    else
      @sidebar_partial = 'users/sidebar/placeholder'
      render 'new'
    end
  end
  
  def new
    @team = Team.find(params[:team_id])
    @event = @team.events.new
    @title = "New event"
    @sidebar_partial = 'users/sidebar/placeholder'
  end

end