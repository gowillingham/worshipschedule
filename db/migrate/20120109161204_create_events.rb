class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :team_id, :null => false
      t.string :name, :null => false
      t.string :description
      t.string :color
      t.datetime :start_at, :null => false
      t.datetime :end_at
      t.boolean :all_day, :null => false, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :teams
  end
end
