class Account < ActiveRecord::Base
  attr_accessible :name, :owner_id

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  has_many :teams, :dependent => :destroy
  has_many :accountships
  has_many :users, :through => :accountships
  
  validates_presence_of :name
  
  def assign_administrators(ids, current_user)
    owner = self.owner
    accountships = self.accountships.find(:all, :include => :user)
    
    accountships.each do |accountship|
      
      # don't modify the current user or owner ..
      unless (accountship.user == current_user) || (accountship.user == owner)
        if ids.include?(accountship.id.to_s)
          unless accountship.admin?
            
            # set this user as account admin ..
            accountship.update_attribute(:admin, true) 
            
            # reset any team administrations for this user ..
            accountship.user.memberships.each do |membership|
              membership.update_attribute(:admin, false)
            end
          end 
        else
          accountship.update_attribute(:admin, false) if accountship.admin?
        end
      end
    end
  end
end
