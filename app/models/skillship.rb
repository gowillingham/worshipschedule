class Skillship < ActiveRecord::Base
  belongs_to :membership
  belongs_to :skill
  has_many :slots
    
  validates :membership_id, :presence => true
  validates :skill_id, :presence => true
end