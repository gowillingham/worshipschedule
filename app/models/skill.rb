class Skill < ActiveRecord::Base
  attr_accessible :name, :description
  
  default_scope :order => :name
  belongs_to :team
  
  has_many :skillships, :dependent => :destroy
  has_many :memberships, :through => :skillships
    
  validates :team_id, :presence => true, :length => { :minimum => 1 }
  validates :name, :presence => true, :length => { :maximum => 100 }
  validates :description, :length => { :maximum => 500 } 
  
  def assign_skillships(membership_ids)
    skillships = self.skillships.find(:all)
    
    # remove the skillships missing from the passed in list ..
    skillships.each do |skillship|
      unless membership_ids.include?(skillship.membership_id.to_s)
        skillship.delete
      end
    end
    
    # add the skillships that don't already exist ..
    membership_ids.each do |id|
      if self.skillships.find_by_membership_id(id).nil?
        self.skillships.create(:membership_id => id)
      end
    end
  end 
end