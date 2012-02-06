module EventsHelper
  
  def slots_for(event)
    # return a two-dimensional array ..
    # => .[0] = user
    # => .[1] = comma-delim list of skills for the passed in event
    
    slots = Slot.find(
      :all,
      :joins => [:event, :skillship => { :membership => :user }],
      :conditions => ['events.id = ?', event.id],
      :order => 'CASE WHEN (LENGTH(last_name) = 0) THEN LOWER(email) ELSE LOWER(last_name) END'
    ) 
    
    if slots.any?
      slots = slots.collect { |slot| [slot.skillship.membership.user, slots.find_all { |sl| sl.skillship.membership_id == slot.skillship.membership_id }.map {|sl| sl.skillship.skill.name }.join(", ")]}
      slots.uniq!
    end
    slots ||= []
  end
end