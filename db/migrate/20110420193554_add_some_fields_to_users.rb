class AddSomeFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :office_phone, :string
    add_column :users, :office_phone_ext, :string
    add_column :users, :home_phone, :string
    add_column :users, :mobile_phone, :string
  end

  def self.down
    remove_column :users, :office_phone
    remove_column :users, :office_phone_ext
    remove_column :users, :home_phone
    remove_column :users, :mobile_phone
  end
end
