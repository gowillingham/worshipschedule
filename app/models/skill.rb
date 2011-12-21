class Skill < ActiveRecord::Base
  attr_accessible :name, :description
  
  default_scope :order => :name
  belongs_to :team
  
  validates :team_id, :presence => true, :length => { :minimum => 1 }
  validates :name, :presence => true, :length => { :maximum => 100 }
  validates :description, :length => { :maximum => 500 }  
end