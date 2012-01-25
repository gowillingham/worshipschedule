class SlotsController < ApplicationController
  before_filter { require_account_or_team_admin(params[:team_id]) }
  before_filter { require_team_for_current_account(params[:team_id]) }
  before_filter { require_team_member(params[:team_id]) }    

end