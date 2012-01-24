class CreateSlots < ActiveRecord::Migration
  def self.up
    create_table :slots do |t|
      t.integer :skillship_id, :null => false
      t.integer :event_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :slots
  end
end
