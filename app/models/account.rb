class Account < ActiveRecord::Base
  attr_accessible :name

  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  has_many :accountships
  has_many :users, :through => :accountships
  
  def assign_administrators(ids, current_user)
    owner = self.owner
    accountships = self.accountships.find(:all, :include => :user)
    
    accountships.each do |accountship|
      
      # don't modify the current user or owner ..
      unless (accountship.user == current_user) || (accountship.user == owner)
        if ids.include?(accountship.id.to_s)
          accountship.update_attribute(:admin, true) unless accountship.admin?
        else
          accountship.update_attribute(:admin, false) if accountship.admin?
        end
      end
    end
  end
end
