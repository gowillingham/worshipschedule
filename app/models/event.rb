class Event < ActiveRecord::Base
  belongs_to :team
    
  attr_accessor :start_at_date, :start_at_time, :end_at_date, :end_at_time

  validates :name, :presence => true, :length => { :minimum => 1, :maximum => 100}
  validates :description, :length => { :maximum => 500 }
  
  validates_date :start_at_date
  validates_time :start_at_time, :allow_blank => true
  
  validates_date :end_at_date, :allow_blank => true, :on_or_after => :start_at_date, :on_or_after_message => 'must be on or after starting time'
  validates_time :end_at_time, :allow_blank => true, :after => :start_at_time, :after_message => 'must be after starting time'
  
  after_validation :set_start_at_end_at
  after_initialize :refresh_readable_attributes
  after_find :refresh_readable_attributes
  
  def time_for_display
    if self.all_day
      "All day"
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
          self.start_at_date = start_at.to_date
          unless end_at.nil?
            self.end_at_date = end_at.to_date
          else
            self.end_at_date = nil
          end        
        else
          self.start_at_date = start_at.to_date
          self.start_at_time = start_at.to_time
          unless end_at.nil?
            self.end_at_date = end_at.to_date
            self.end_at_time = end_at.to_time
          else
            self.end_at_date = nil
            self.end_at_time = nil
          end
        end
      end
    end
  
    # sets private members storing event dates/times right after validation
    def set_start_at_end_at
      if end_at_date.blank?
        if start_at_time.blank?
          self.all_day = true
          self.start_at = start_at_date
          self.end_at = nil
        else
          if end_at_time.blank?
            self.all_day = false
            self.start_at = DateTime.new(Date.parse(start_at_date).year, Date.parse(start_at_date).month, Date.parse(start_at_date).day, Time.parse(start_at_time).hour, Time.parse(start_at_time).min, 0, 0)
            self.end_at = nil
          else
            self.all_day = false
            self.start_at = DateTime.new(Date.parse(start_at_date).year, Date.parse(start_at_date).month, Date.parse(start_at_date).day, Time.parse(start_at_time).hour, Time.parse(start_at_time).min, 0, 0)
            self.end_at = DateTime.new(Date.parse(start_at_date).year, Date.parse(start_at_date).month, Date.parse(start_at_date).day, Time.parse(start_at_time).hour, Time.parse(start_at_time).min, 0, 0)
          end
        end
      else
        # start_at_date + end_at_date
        self.all_day = true
        self.start_at = start_at_date
        self.end_at = end_at_date
      end
    end
end