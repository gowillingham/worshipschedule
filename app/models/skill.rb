class Skill < ActiveRecord::Base
  attr_accessible :name, :description
  
  default_scope :order => :name
  belongs_to :team
  
  has_many :skillships, :dependent => :destroy
  has_many :memberships, :through => :skillships
    
  validates :team_id, :presence => true, :length => { :minimum => 1 }
  validates :name, :presence => true, :length => { :maximum => 100 }
  validates :description, :length => { :maximum => 500 }  
end