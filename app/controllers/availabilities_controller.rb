class AvailabilitiesController < AccountsController
  before_filter { require_team_member params[:team_id] }
  
  def create
    Availability.create(params[:availability])
    
    respond_to do |format|
      format.html { render :nothing => true }
#      format.json { render :json => @membership }
    end
  end
end