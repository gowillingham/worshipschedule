class Event < ActiveRecord::Base
  validates :name, :presence => true, :length => { :minimum => 1, :maximum => 100}
  validates :description, :length => { :maximum => 500 }
end