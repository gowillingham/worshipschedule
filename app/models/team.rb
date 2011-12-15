class Team < ActiveRecord::Base
  belongs_to :account
  
  default_scope :order => 'name ASC'
  
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  
  validates_presence_of :account_id
  validates_presence_of :name
  
  def assign_administrators(ids, current_user)
    memberships = self.memberships.find(:all, :include => :user)
    
    memberships.each do |membership|
      
      # don't modify current_user, owner, or account admins
      if ids.include?(membership.id.to_s)
        membership.update_attribute(:admin, true) unless membership.admin?
      else
        membership.update_attribute(:admin, false) if membership.admin?
      end
    end
  end
  
  def self.add_all_account_users(account, team)
    team.users = account.users
    Membership.update_all({ :active => true }, { :team_id => team.id })
  end
  
  def self.remove_all_account_users(team)
    Membership.update_all({ :active => false }, { :team_id => team.id })
  end
  
  def self.member?(user)
    self.users.exists?(user)
  end
end
