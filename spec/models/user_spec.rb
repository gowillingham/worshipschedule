require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = {
      :first_name => 'Nigel',
      :last_name => 'Tufnel',
      :email => 'email@example.com',
      :password => 'password',
      :password_confirmation => 'password'
    }
  end
  
  it "should create a new instance" do
    User.create! @attr
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
  
  describe "password validations" do
    
    it "should require a password" do
      User.new(@attr.merge(:password => '', :password_confirmation => '')).should_not be_valid
    end
    
    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => 'invalid')).should_not be_valid
    end
    
    it "should reject short passwords" do
      short = "a" * 3
      User.new(@attr.merge(:password => short, :password_confirmation => short)).should_not be_valid
    end
    
    it "should reject long passwords" do
      long = "a" * 51
      User.new(@attr.merge(:password => long, :password_confirmation => long)).should_not be_valid
    end
  end
  
  describe "password encryption" do
    
    before(:each) do
      @user = User.create! @attr
    end
    
    it "should have an encrypted_password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
      
      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should be false if the passwords don't match" do
        @user.has_password?('invalid').should_not be_true
      end
    end
    
    describe "authenticate method" do
      
      it "should return nil on email/password mismatch" do
        user = User.authenticate(@attr[:email], 'wrong_password')
        user.should be_nil
      end
      
      it "should return nil for an email address with no user" do
        user = User.authenticate('does_not@exist.com', 'password')
        user.should be_nil
      end
      
      it "should return the user on email/password match" do
        user = User.authenticate(@attr[:email], @attr[:password])
        user.should == @user
      end
    end
  end
  
  describe "admin attribute" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    
    it "should not be an admin by default" do
      @user.should_not be_admin
    end
    
    it "should be convertible to an admin" do
      @user.toggle1(:admin)
      @user.should be_admin
    end
  end
  
  describe "accountships" do
    
    before(:each) do
      @user = User.create!(@attr)
      @account = Factory(:account)
    end
    
    it "should have an accountships method" do
      @user.should respond_to(:accountships)
    end
    
    it "should have an accounts method" do
      @user.should respond_to(:accounts)
    end
  end
end
