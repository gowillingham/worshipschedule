class Event < ActiveRecord::Base
  belongs_to :team
  
  validates :name, :presence => true, :length => { :minimum => 1, :maximum => 100}
  validates :description, :length => { :maximum => 500 }
  
  validates_datetime :start_at
  validates_datetime :end_at, :allow_nil => true, :on_or_after => :start_at
end