class Team < ActiveRecord::Base
  belongs_to :account
  
  default_scope :order => 'name ASC'
  
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  
  validates_presence_of :account_id
  validates_presence_of :name
end
