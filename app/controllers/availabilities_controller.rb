class AvailabilitiesController < ApplicationController
  before_filter(:only => :create) { require_memberships_for_current_team(params[:team_id], [params[:availability][:membership_id]]) }
  before_filter(:only => :create) { require_event_for_current_team(params[:team_id], params[:availability][:event_id])}
  before_filter(:only => :update) { require_availability_for_current_team(params[:team_id], params[:id]) }

  respond_to :html
  
  def update
    @team = Team.find(params[:team_id])
    @availability = Availability.find(params[:id])
    @event = Event.find(@availability.event_id)

    if @availability.update_attributes(params[:availability])
      respond_with do |format|
        format.html do 
          if request.xhr?
            render  :partial => 'events/availability_chooser_for', 
                    :locals => { :user => current_user, :team => @team, :event => @event },
                    :status => :ok
          else
            flash[:success] = 'The free/available status for the event was changed'
            redirect_to team_events_url(@team)
          end
        end 
      end
    else
      if request.xhr?
        render :nothing => true, :status => :internal_server_error
      else
        flash[:error] = 'There was a problem and the changes were not saved'
        redirect_to team_events_url(@team)
      end
    end     
  end

  def create
    @team = Team.find(params[:team_id])
    @availability = Availability.new(params[:availability])
    @event = Event.find(params[:availability][:event_id])

    if @availability.save
      respond_with do |format|
        format.html do 
          if request.xhr?
            render  :partial => 'events/availability_chooser_for', 
                    :locals => { :user => current_user, :team => @team, :event => @event },
                    :status => :ok
          else
            redirect_to team_events_url(@team)
          end
        end 
      end
    else
      if request.xhr?
        render :nothing => true, :status => :internal_server_error
      else
        flash[:error] = 'There was a problem and the changes were not saved'
        redirect_to team_events_url(@team)
      end
    end     
  end
  
  private
  
    def require_availability_for_current_team(team_id, availability_id)
      availabilities = Availability.find(
        :all,
        :joins => { :event => :team },
        :conditions => ['teams.id = ?', team_id]
      ).map { |availability| availability.id.to_s }

      unless availabilities.include?(availability_id.to_s)
        if request.xhr?
          render :nothing => true, :status => :forbidden
        else
          flash[:error] = 'You do not have permission to modify that availability'
          redirect_to(current_user)
        end
      end
    end
end