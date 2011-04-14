class IndexesForAccountships < ActiveRecord::Migration
  def self.up
    add_index :accountships, [:account_id]
    add_index :accountships, [:user_id]
  end

  def self.down
  end
end
