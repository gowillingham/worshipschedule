class AddIndexesToEvents < ActiveRecord::Migration
  def self.up
    add_index :events, :start_at
    add_index :events, :team_id
  end

  def self.down
  end
end
