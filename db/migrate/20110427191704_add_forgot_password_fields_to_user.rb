class AddForgotPasswordFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :forgot_hash, :string
    add_column :users, :forgot_hash_created_at, :datetime
  end

  def self.down
    remove_column :users, :forgot_hash
    remove_column :users, :forgot_hash_created_at
  end
end
