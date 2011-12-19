class Skill < ActiveRecord::Base
  attr_accessible :name, :description
  
  default_scope :order => :name
  belongs_to :team
  
end