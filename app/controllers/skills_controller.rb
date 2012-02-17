class SkillsController < ApplicationController
  before_filter(:except => [:index, :show]) { require_account_or_team_admin(params[:team_id]) }
  before_filter { require_team_for_current_account(params[:team_id]) }
  before_filter(:only => [:destroy, :edit, :update, :show, :skillships, :update_skillships]) { require_skill_for_current_team(params[:team_id], params[:id]) }
  before_filter(:only => [:update_skillships]) { require_memberships_for_current_team(params[:team_id], params[:membership_ids] || []) }
  before_filter { require_team_member(params[:team_id]) }
  
  def update_skillships
    @team = Team.find(params[:team_id])
    @skill = Skill.find(params[:id])
    
    @skill.assign_skillships(params[:membership_ids] || [])
    flash[:success] = "The members with this skill were changed"
    redirect_to edit_team_skill_url(@team, @skill)
  end
  
  def skillships
    @team = Team.find(params[:team_id])
    @skill = Skill.find(params[:id])
    @sidebar_partial = 'users/sidebar/placeholder'
    @title = "Assign skill"
    @memberships = @team.memberships.joins(:user).where(:active => true).order('CASE WHEN (LENGTH(last_name) = 0) THEN LOWER(email) ELSE LOWER(last_name) END')
  end
  
  def show
    @team = Team.find(params[:team_id])
    @skill = Skill.find(params[:id])
    @skillships = Skillship.joins(:membership).where("skillships.skill_id = ? AND memberships.active = ?", @skill.id, true)
    @skillships.sort! { |a,b,| a.membership.user.sortable_name.downcase <=> b.membership.user.sortable_name.downcase }
    @sidebar_partial = 'skills/sidebar/show'
    @title = "Skill details"
  end
  
  def update
    @team = Team.find(params[:team_id])
    @skill = Skill.find(params[:id])
    if @skill.update_attributes(params[:skill])
      flash[:success] = "The changes to the skill were saved"     
      redirect_to team_skills_url(@team)
    else
      @sidebar_partial = 'skills/sidebar/show'
      render 'edit'
    end
  end
  
  def edit
    @team = Team.find(params[:team_id])
    @skill = Skill.find(params[:id])
    @skillships = Skillship.joins(:membership).where("skillships.skill_id = ? AND memberships.active = ?", @skill.id, true)
    @skillships.sort! { |a,b,| a.membership.user.sortable_name.downcase <=> b.membership.user.sortable_name.downcase }
    @sidebar_partial = 'skills/sidebar/edit'
    @title = 'Skill settings'
    
    render 'edit'
  end
  
  def destroy 
    @skill = Skill.find(params[:id])
    @skill.delete
    
    redirect_to team_skills_url(@team), :flash => { :success => "The skill was removed from this team" }
  end
  
  def index
    @team = Team.find(params[:team_id])
    @skills = @team.skills
    membership = Membership.where('user_id = ? AND team_id = ? and active = ?', current_user.id, @team.id, true).first
    @skillships = Skillship.where('membership_id = ?', membership.id).all unless membership.nil?
    @sidebar_partial = 'skills/sidebar/index'
    @title = 'Team skills'
    render 'index'
  end
  
  def create
    @team = Team.find(params[:team_id])
    @skill = @team.skills.new(params[:skill])
    if @skill.save
      flash[:success] = 'The new skill was successfully saved'
      redirect_to team_skills_url(@team)
    else
      @sidebar_partial = 'users/sidebar/placeholder'
      @title = 'New skill'
      render 'new'
    end
  end
  
  def new
    @team = Team.find(params[:team_id])
    @skill = @team.skills.build
    @title = 'New skill'
    @sidebar_partial = 'users/sidebar/placeholder'
  end
  
  private
  
    def require_skill_for_current_team(team_id, skill_id)
      skill = Skill.find(skill_id)
      current_team = Team.find(team_id)
      unless current_team.skills.exists?(skill)
        redirect_to current_user, :flash => { :error => "You don't have permission to modify that skill" }
      end      
    end
end
