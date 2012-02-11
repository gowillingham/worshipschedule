module TeamsHelper
  
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
end
