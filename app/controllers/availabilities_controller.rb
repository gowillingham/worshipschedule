class AvailabilitiesController < AccountsController
  before_filter { require_team_member params[:team_id] }

  def create
    @team = Team.find(params[:team_id])
    
    # => create a new record or find the existing and update it ..
    # => perhaps add upsert method to model ..?
    
    @availability = Availability.where(
      'membership_id = ? AND event_id =?', params[:availability][:membership_id], params[:availability][:event_id]
    ).first
    
    if @availability.nil?
      @availability = Availability.new(params[:availability])
      @availability.free = true if params[:free?]
    else
      if params[:free?]
        @availability.free = true
      else
        @availability.free = false
      end
    end
    
    if @availability.save
      respond_to do |format|
        format.html { redirect_to team_events_url(@team) }
      end
    end
  end
end