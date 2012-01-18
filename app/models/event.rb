class Event < ActiveRecord::Base
  belongs_to :team
    
  attr_accessor :start_at_date, :start_at_time, :end_at_date, :end_at_time
  attr_accessible :start_at_date, :start_at_time, :end_at_date, :end_at_time, :name, :description, :team_id
  attr_readonly :start_at, :end_at, :all_day
  
  validates :name, :presence => true, :length => { :minimum => 1, :maximum => 100}
  validates :description, :length => { :maximum => 500 }
  
  validates_date :start_at_date, :allow_blank => false
  validates_time :start_at_time, :allow_blank => true
  
  validates_date :end_at_date, :allow_blank => true, :after => :start_at_date, :after_message => 'must be after starting date'
  validates_time :end_at_time, :allow_blank => true, :after => :start_at_time, :after_message => 'must be after starting time'
  
  before_save :set_start_at_end_at
  after_initialize :refresh_readable_attributes
  after_find :refresh_readable_attributes
  
  def time_for_display
    if self.all_day
      unless end_at.nil?
        "Multi day"
      else
        "All day"
      end
    else
      self.start_at.to_time.strftime("%l:%M%P").downcase.chop
    end
  end
  
  private 
  
    def refresh_readable_attributes
      
      unless start_at.nil?
        if all_day?
          self.start_at_time = nil
          self.end_at_time = nil
          self.start_at_date = start_at.to_date.strftime("%Y-%m-%d")
          if end_at.nil?
            self.end_at_date = nil
          else
            self.end_at_date = end_at.to_date.strftime("%Y-%m-%d")
          end
        end
          
        if !all_day?
          self.start_at_date = start_at.to_date.strftime("%Y-%m-%d")
          self.start_at_time = start_at.to_time.strftime("%l:%M %P")
          self.end_at_date = nil
          if end_at.nil?
            self.end_at_time = nil
          else
            self.end_at_time = end_at.to_time.strftime("%l:%M %P")
          end
        end
      end      
    end
  
    def set_start_at_end_at
      
      if start_at_time.blank?
        
        # no start_at_time so ..        
        if end_at_date.blank?
          # its all_day, start_at_date only, disregard times
          self.all_day = true
          self.start_at = DateTime.new(DateTime.parse(start_at_date).year, DateTime.parse(start_at_date).month, DateTime.parse(start_at_date).day, 0, 0, 0, 0) unless start_at_date.blank?        
          self.end_at = nil
        else
          # its all_day, start_at-date + end_at_date, disregard times 
          self.all_day = true
          self.start_at = DateTime.new(DateTime.parse(start_at_date).year, DateTime.parse(start_at_date).month, DateTime.parse(start_at_date).day, 0, 0, 0, 0) unless start_at_date.blank?        
          self.end_at = DateTime.new(DateTime.parse(end_at_date).year, DateTime.parse(end_at_date).month, DateTime.parse(end_at_date).day, 0, 0, 0, 0) unless start_at_date.blank?
        end
      end
      
      if !start_at_time.blank?  
        # has start_at_time so ..
        if end_at_time.blank? 
          # its not all_day, start_at_date + start_at_time, disregard end_at_time + end_at_date
          self.all_day = false
          self.start_at = DateTime.new(DateTime.parse(start_at_date).year, DateTime.parse(start_at_date).month, DateTime.parse(start_at_date).day, DateTime.parse(start_at_time).hour, DateTime.parse(start_at_time).min, 0, 0) unless start_at_date.blank?
          self.end_at = nil
        else
          # its not all_day, start_at_date = end_at_date, save times too
          self.all_day = false
          self.start_at = DateTime.new(DateTime.parse(start_at_date).year, DateTime.parse(start_at_date).month, DateTime.parse(start_at_date).day, DateTime.parse(start_at_time).hour, DateTime.parse(start_at_time).min, 0, 0) unless start_at_date.blank?
          self.end_at = DateTime.new(DateTime.parse(start_at_date).year, DateTime.parse(start_at_date).month, DateTime.parse(start_at_date).day, DateTime.parse(end_at_time).hour, DateTime.parse(end_at_time).min, 0, 0) unless start_at_date.blank?
        end
      end 
    end
end