class RemoveColorFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :color
  end

  def self.down
    add_column :events, :color
  end
end
