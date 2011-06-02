class Membership < ActiveRecord::Base
  belongs_to :team
  belongs_to :user
  
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
end
