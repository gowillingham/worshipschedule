require 'digest'

class User < ActiveRecord::Base 
  attr_accessor :password
  attr_accessible :email, :first_name, :last_name, :home_phone, :mobile_phone, :office_phone, :office_phone_ext, :password, :password_confirmation
  
  has_many :accountships
  has_many :accounts, :through => :accountships
  
  validates :first_name, :length => { :maximum => 50 }
  validates :last_name, :length => { :maximum => 50 }
  
  validates :password, :presence => true, :confirmation => true, :length => { :within => 4..50 }
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, :presence => true, :format => { :with => email_regex }
  
  phone_regex = /^[\(\)0-9\- \+\.]{10,20}$/
  validates_format_of :home_phone, :with => phone_regex
  validates_format_of :office_phone, :with => phone_regex
  validates_format_of :mobile_phone, :with => phone_regex

  before_save :encrypt_password
  
  def self.authenticate(email, submitted_password)
    user = find_by_email email
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end
  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def name
    "#{self.first_name} #{self.last_name}"
  end
  
  def name_or_email
    unless self.first_name.blank?
      "#{self.first_name} #{self.last_name}"
    else
      self.email
    end
  end
  
  private
  
    def encrypt_password
      self.salt = make_salt if self.new_record?
      self.encrypted_password = encrypt(self.password)
    end
    
    def encrypt(string)
      secure_hash("#{self.salt}--#{string}")
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{self.password}")
    end
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
