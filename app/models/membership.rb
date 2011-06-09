class Membership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  
  scope :active, where(:active => true)
  scope :admin, where(:admin => true)
  
  validates :team_id, :presence => true
  validates :user_id, :presence => true
  
  def self.toggle_active(team_id, user_id)
    membership = find(:first, :conditions => ['user_id = ? AND team_id = ?', user_id, team_id])
    if membership.nil?
      membership = Membership.create(:team_id => team_id, :user_id => user_id, :active => true)
    else
      membership.toggle(:active).save
    end
    
    return membership
  end
  
  def self.set_to_active(team_id, user_id)
    membership = find(:first, :conditions => ['user_id = ? AND team_id = ?', user_id, team_id])
    if membership.nil?
      membership = Membership.create(:team_id => team_id, :user_id => user_id, :active => true)
    else
      membership.active = true
      membership.save
    end
  end
  
  def self.set_to_inactive(team_id, user_id)
    membership = find(:first, :conditions => ['user_id = ? AND team_id = ?', user_id, team_id])
    unless membership.nil?
      membership.active = false
      membership.save
    end
  end
end
