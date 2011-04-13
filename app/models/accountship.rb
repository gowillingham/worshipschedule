class Accountship < ActiveRecord::Base
  belongs_to :account
  belongs_to :user
  
  validates :account_id, :presence => true
  validates :user_id, :presence => true
end
