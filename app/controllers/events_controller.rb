class EventsController < ApplicationController
  before_filter(:except => [:show, :index]) { require_account_or_team_admin(params[:team_id]) }
  before_filter { require_team_for_current_account(params[:team_id]) }
  before_filter(:except => [:new, :create, :index]) { require_event_for_current_team(params[:team_id], params[:id])}
  before_filter { require_team_member(params[:team_id]) }
  before_filter(:only => :slots) { require_skillships_for_current_team(params[:team_id], params[:add] ||= [], params[:remove] ||= []) }
  
  def slots
    @team = Team.find(params[:team_id])
    @event = Event.find(params[:id]) 

    if params[:add_slots] && (params[:add] ||= []).any?
      params[:add].each { |id| Slot.create(:event_id => @event.id, :skillship_id => id) unless id.blank? }
    elsif params[:remove_slots] && (params[:remove] ||= []).any?
      params[:remove].each { |id| Slot.where(:event_id => @event.id, :skillship_id => id).first.destroy unless id.blank? }
    end

    redirect_to slots_team_url(@team)
  end
  
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
    @slots = Slot.find(
      :all,
      :joins => [:event, :skillship => [:skill, { :membership => :user }]],
      :conditions => ['users.id = ? AND memberships.team_id = ?', current_user.id, @team.id]
    )
    @slots.sort! { |a,b| b.event.start_at <=> a.event.start_at}
    
    @title = 'All events'
    @sidebar_partial = 'events/sidebar/index'
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
  
    def require_skillships_for_current_team(team_id, add_ids, remove_ids)
      included = true
      team = Team.find(team_id)
    
      membership_ids = Skillship.find(add_ids + remove_ids).collect { |skillship| skillship.membership_id }
      membership_ids.each do |membership_id|
        unless team.membership_ids.include?(membership_id)
          included = false
        end
      end
    
      if !included
        redirect_to slots_team_url(team), :flash => { :error => "You do not have permission to modify one (or more) of the members you selected " }
      end
    end
end