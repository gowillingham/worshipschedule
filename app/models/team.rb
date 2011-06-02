class Team < ActiveRecord::Base
  belongs_to :account
  
  default_scope :order => 'name ASC'
  
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  
  validates_presence_of :account_id
  validates_presence_of :name
  
  def self.add_all_account_users(account, team)
    team.users = account.users
    Membership.update_all({ :active => true }, { :team_id => team.id })
    # find existing users and set active to true ..
    # insert missing users ..
  end
  
  def self.remove_all_account_users(team)
    Membership.update_all({ :active => false }, { :team_id => team.id })
  end
end
