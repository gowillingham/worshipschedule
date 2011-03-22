require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = { :first_name => 'Nigel', :last_name => 'Tufnel', :email => 'email@example.com' }
  end
  
  it "should create a new instance" do
    User.create! @attr
  end
  
  it "should require a first_name" do
    user = User.new @attr.merge(:first_name => '')
    user.should_not be_valid
  end
  
  it "should require a last_name" do
    user = User.new @attr.merge(:last_name => '')
    user.should_not be_valid
  end
  
  it "should require an email" do
    user = User.new @attr.merge(:email => '')
    user.should_not be_valid
  end
  
  it "should reject first_names that are too long" do
    long_name = "a" * 51
    user = User.new @attr.merge(:first_name => long_name)
    user.should_not be_valid
  end
  
  it "should reject last_names that are too long" do
    long_name = "a" * 51
    user = User.new @attr.merge(:last_name => long_name)
    user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      user = User.new @attr.merge(:email => address)
      user.should_not be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      user = User.new @attr.merge(:email => address)
      user.should be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    User.create! @attr
    user = User.new(@attr)
    user.should_not be_valid
  end
  
  it "should reject duplicate email addresses by case" do
    upcased_email = @attr[:email].upcase
    User.create! @attr.merge(:email => upcased_email)
    user = User.new @attr
    user.should_not be_valid
  end
end
