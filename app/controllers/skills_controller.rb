class SkillsController < ApplicationController
  before_filter { require_account_or_team_admin(params[:team_id]) }
  before_filter { require_team_for_current_account(params[:team_id]) }
  
  def create
    @team = Team.find(params[:team_id])
    @skill = @team.skills.new(params[:skill])
    if @skill.save
      flash[:success] = 'The new skill was successfully saved'
      redirect_to team_skills_url(@team)
    else
      @sidebar_partial = 'users/sidebar/placeholder'
      render 'new'
    end
  end
  
  def new
    @team = Team.find(params[:team_id])
    @skill = @team.skills.build
    @title = 'New skill'
    @sidebar_partial = 'users/sidebar/placeholder'
  end
end
