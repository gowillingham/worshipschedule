class AddIdToAccountships < ActiveRecord::Migration
  def self.up
    add_column :accountships, :id, :primary_key
  end

  def self.down
    remove_column :accountships, :id
  end
end
