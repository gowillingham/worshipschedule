class EventsController < ApplicationController
  before_filter(:except => [:show, :index]) { require_account_or_team_admin(params[:team_id]) }
  before_filter { require_team_for_current_account(params[:team_id]) }
  
  def new
    @team = Team.find(params[:team_id])
    @event = @team.events.new
    @title = "New event"
    @sidebar_partial = 'users/sidebar/placeholder'
  end

end