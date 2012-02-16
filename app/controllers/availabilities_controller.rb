class AvailabilitiesController < AccountsController
  before_filter { require_team_member params[:team_id] }
  respond_to :html
  
  def update
    @team = Team.find(params[:team_id])
    @availability = Availability.find(params[:id])
    @event = Event.find(@availability.event_id)
    
    @availability.approved = true
    if params[:free?]
      @availability.free = true
    else
      @availability.free = false
    end

    if @availability.save
      respond_with do |format|
        format.html do 
          if request.xhr?
            render  :partial => 'events/availability_chooser_for', 
                    :locals => { :user => current_user, :team => @team, :event => @event }
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
    
    @availability.approved = true
    @availability.free = true if params[:free?]
    
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
end