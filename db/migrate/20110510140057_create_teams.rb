class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.string :name
      t.string :banner_text
      t.integer :account_id

      t.timestamps
    end
    
    add_index :teams, :name
  end

  def self.down
    drop_table :teams
  end
end
