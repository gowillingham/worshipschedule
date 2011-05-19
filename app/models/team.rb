class Team < ActiveRecord::Base
  belongs_to :account
  
  validates_presence_of :account_id
  validates_presence_of :name
  
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
end
