class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :team_id, :null => false
      t.integer :user_id, :null => false
      t.boolean :admin, :default => false
      t.timestamps
    end
    
    add_index :memberships, [:team_id, :user_id], :unique => true
  end

  def self.down
    drop_table :memberships
  end
end
