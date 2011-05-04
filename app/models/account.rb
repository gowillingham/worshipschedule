class Account < ActiveRecord::Base
  attr_accessible :name

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  has_many :accountships
  has_many :users, :through => :accountships
end
