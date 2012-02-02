module TeamsHelper
  
  def popup_form_for_cell
    # <table class="picker">
    #   <tbody>
    #     <tr class="label">
    #       <td>Assigned</td>
    #       <td></td>
    #       <td>Not assigned</td>
    #     </tr>
    #     <tr>
    #       <td>
    #         <% remove_these = events[i].slots.find_all { |slot| slot.skillship.skill_id == skill.id }.map { |slot| [slot.skillship.membership.user.name_or_email, slot.skillship_id] } %>
    #         <%= select_tag :remove, options_for_select(remove_these), :multiple => true %>                            
    #       </td>
    #       <td class="center">
    #         <%= submit_tag '<<' %>
    #         <br />
    #         <%= submit_tag '>>' %>                                  
    #       </td>
    #       <td>
    #         <% selected = events[i].slots.map { |sl| sl.skillship_id }%>
    #         <% add_these = @skillships.find_all { |s| (s.skill_id == skill.id) && (!selected.include?(s.id)) && s.membership.active = true }.map { |s| [Skillship.find(s.id).membership.user.name_or_email, s.id] }%>
    #         <%= select_tag :add, options_for_select(add_these), :multiple => true %>                                    
    #       </td>
    #     </tr>
    #   </tbody>
    # </table>                          
  end
  
  def slotted_for_cell(all_slots, skill_id, event_id)
		slots = all_slots.find_all { |slot| (slot.skillship.skill_id == skill_id) && (slot.event.id == event_id) }
		
		if slots.any?
			content_tag :ul do
  			slots.collect do |slot|
  				concat(content_tag :li, slot.skillship.membership.user.name_or_email)
  			end
		  end
    end
  end
  
  def team_member?(member, team)
    if member.teams.exists?(team)
      member.memberships.where(:team_id => team.id).first.active?
    else
      false
    end
  end
end
