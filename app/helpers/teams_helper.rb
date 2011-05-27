module TeamsHelper
  def team_member?(member, team)
    if member.teams.exists?(team)
      member.memberships.where(:team_id => team.id).first.active?
    else
      false
    end
  end
end
