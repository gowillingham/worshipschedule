class DropAccountships < ActiveRecord::Migration
  def self.up
    drop_table :accountships
  end

  def self.down
  end
end
