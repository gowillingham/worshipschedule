class AvailabilitiesController < AccountsController
  before_filter { require_team_member params[:team_id] }

  def update
    @team = Team.find(params[:team_id])
    @availability = Availability.find(params[:id])
    @availability.approved = true
    if params[:free?]
      @availability.free = true
    else
      @availability.free = false
    end

    if @availability.save
      respond_to do |format|
        format.html { redirect_to team_events_url(@team) }
      end
    end    
  end

  def create
    @team = Team.find(params[:team_id])
    @availability = Availability.new(params[:availability])
    @availability.free = true if params[:free?]
    @availability.approved = true
    
    if @availability.save
      respond_to do |format|
        format.html { redirect_to team_events_url(@team) }
      end
    end
  end
end