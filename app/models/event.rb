class Event < ActiveRecord::Base
  belongs_to :team
  has_many :slots, :dependent => :destroy
    
  attr_accessor :start_at_date, :start_at_time, :end_at_date, :end_at_time
  attr_accessible :team_id, :start_at_date, :start_at_time, :end_at_date, :end_at_time, :name, :description
  
  validates :name, :length => { :maximum => 100}
  validates :description, :length => { :maximum => 500 }
  
  validates_date :start_at_date, :allow_blank => false
  validates_time :start_at_time, :allow_blank => true
  
  validates_date :end_at_date, :allow_blank => true, :after => :start_at_date, :after_message => 'must be after starting date'
  validates_time :end_at_time, :allow_blank => true, :after => :start_at_time, :after_message => 'must be after starting time'
  
  before_save :set_start_at_end_at
  before_save do |event|
    event.name = 'Untitled event' if event.name.blank?
  end
  
  after_initialize :refresh_readable_attributes
  after_find :refresh_readable_attributes
  
  def when_range_text
    str = start_at_date.to_date.strftime("%A, %d %B")   
    if all_day?
      str << " - #{end_at_date.to_date.strftime("%A, %d %B")}" unless end_at_date.nil?
    else
      str << ", #{Time.parse(start_at_time).strftime("%l:%M%P").downcase.strip.chop}"
      str << " - #{Time.parse(end_at_time).strftime("%l:%M%P").downcase.strip.chop}" unless end_at_time.nil?
    end
    str
  end
  
  def all_day_text
    if all_day?
      unless end_at.nil?
        "Multi day"
      else
        "All day"
      end
    else
      Time.parse(start_at_time).strftime("%l:%M%P").downcase.chop
    end
  end
  
  private 
  
    def refresh_readable_attributes
      
      unless start_at.nil?
        if all_day?
          self.start_at_time = nil
          self.end_at_time = nil
          self.start_at_date = start_at.to_date.strftime("%Y-%m-%d").strip
          if end_at.nil?
            self.end_at_date = nil
          else
            self.end_at_date = end_at.to_date.strftime("%Y-%m-%d").strip
          end
        end
          
        if !all_day?
          self.start_at_date = start_at.to_date.strftime("%Y-%m-%d").strip
          self.start_at_time = start_at.to_time.strftime("%l:%M %P").strip
          self.end_at_date = nil
          if end_at.nil?
            self.end_at_time = nil
          else
            self.end_at_time = end_at.to_time.strftime("%l:%M %P").strip
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
          self.start_at = DateTime.new(DateTime.parse(start_at_date).year, DateTime.parse(start_at_date).month, DateTime.parse(start_at_date).day, 0, 0, 0, 0)        
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