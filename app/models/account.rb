class Account < ActiveRecord::Base
  attr_accessible :name
  
  has_many :accountships
  has_many :users, :through => :accountships
end
