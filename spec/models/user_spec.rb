require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = {
      :first_name => 'Nigel',
      :last_name => 'Tufnel',
      :email => 'email@example.com',
      :password => 'password',
      :password_confirmation => 'password',
      :home_phone => '5556667777',
      :office_phone => '5556667777',
      :mobile_phone => '5556667777',
      :office_phone_ext => 'x225'
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
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      user = User.new @attr.merge(:email => address)
      user.should_not be_valid
    end
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      user = User.new @attr.merge(:email => address)
      user.should be_valid
    end
  end
  
  it "should reject invalid phone numbers" do
    user = User.new @attr.merge(:mobile_phone => '999-888-7777x24')
    user.should_not be_valid
    user = User.new @attr.merge(:mobile_phone => '123456789')
    user.should_not be_valid
    user = User.new @attr.merge(:mobile_phone => 'adbfjdksl')
    user.should_not be_valid
  end
  
  it "should accept valid phone numbers" do
    phones = %w[999-888-7777 (612)435-2121 868.777.5555 9524316341]
    phones.each do |phone|
      user = User.new @attr.merge(:mobile_phone => phone)
      user.should be_valid
    end
    user = User.new @attr.merge(:mobile_phone => '435 634 2222')
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
    
    describe "sortable_name method" do
      it "should return the last_name if provided" do
        has_names = Factory(:user, :email => Factory.next(:email))        
        User.find(has_names.id).sortable_name.should eq(has_names.last_name)
      end
      
      it "should return first_name if no last_name is provided" do
        no_last_name = Factory(:user, :email => Factory.next(:email), :last_name => nil)
        User.find(no_last_name.id).sortable_name.should eq(no_last_name.first_name)        
      end 
      
      it "should return email if no first_name or last_name is provided" do
        no_first_or_last_name = Factory(:user, :email => Factory.next(:email), :last_name => nil, :first_name => nil)
        User.find(no_first_or_last_name.id).sortable_name.should eq(no_first_or_last_name.email)
      end
    end
    
    describe "admin?(account) method" do
      it "should return the user's admin status as a boolean" do
        account = Factory(:account, :name => "Test")
        user = Factory(:user, :email => Factory.next(:email))
        accountship = account.accountships.create(:user_id => user.id, :admin => true)
        
        user.admin?(account).should be_true
      end
    end 
    
    describe "owner?(account) method" do
      it "should return the user's owner status as a boolean" do
        account = Factory(:account, :name => "Test")
        user = Factory(:user, :email => Factory.next(:email))
        account.owner_id = user.id
        account.save
        accountship = account.accountships.create(:user_id => user.id)
        
        user.owner?(account).should be_true
      end
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
  
  describe "memberships" do
    
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have a memberships method" do
      @user.should respond_to(:memberships)
    end
    
    it "should have a teams method" do
      @user.should respond_to(:teams)
    end
  end
end
