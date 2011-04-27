class RemoveColumnForgotSaltAndAddIndex < ActiveRecord::Migration
  def self.up
    remove_column :users, :forgot_salt
    add_index :users, :forgot_hash, :unique => true
  end

  def self.down
    add_column :users, :forgot_salt, :string
    remove_index :users, :forgot_hash
  end
end
