class AddIndexesToSlots < ActiveRecord::Migration
  def self.up
    add_index :slots, :event_id, :name => "index_slots_on_event_id"
    add_index :slots, [:event_id, :skillship_id], :unique => true, :name => "index_slots_on_event_id_and_skillship_id"
  end

  def self.down
    remove_index :slots, :name => "index_slots_on_event_id"
    remove_index :slots, :name => "index_slots_on_event_id_and_skillship_id"
  end
end
