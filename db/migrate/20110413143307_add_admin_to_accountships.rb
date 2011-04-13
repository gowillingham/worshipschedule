class AddAdminToAccountships < ActiveRecord::Migration
  def self.up
    add_column :accountships, :admin, :boolean, :default => false
  end

  def self.down
    remove_column :accountships, :admin
  end
end
