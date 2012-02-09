class CreateAvailabilities < ActiveRecord::Migration
  def self.up
    create_table :availabilities do |t|
      t.integer :membership_id, :null => false
      t.integer :event_id, :null => false
      t.boolean :free, :default => false
      t.boolean :approved, :default => true

      t.timestamps
    end
    
    add_index :availabilities, [:event_id, :membership_id], :unique => true, :name => 'index_availabilities_on_event_id_and_membership_id'
  end

  def self.down
    drop_table :availabilities
  end
end
