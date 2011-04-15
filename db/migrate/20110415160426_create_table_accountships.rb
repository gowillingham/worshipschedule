class CreateTableAccountships < ActiveRecord::Migration
  def self.up
    create_table :accountships do |t|
      t.integer :user_id, :null => false
      t.integer :account_id, :null => false
      t.boolean :admin, :default => false
      
      t.timestamps
    end
    add_index :accountships, [:user_id, :account_id], :unique => true
    add_index :accountships, :user_id
    add_index :accountships, :account_id
  end

  def self.down
    drop_table :accountships
  end
end
