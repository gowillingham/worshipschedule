class Accountship < ActiveRecord::Migration
  def self.up
    create_table :accountships, :id => false do |t|
      t.references :account, :null => false
      t.references :user, :null => false
    end
    
    add_index :accountships, [:account_id, :user_id], :unique => true
  end

  def self.down
    drop_table :accountships
  end
end
