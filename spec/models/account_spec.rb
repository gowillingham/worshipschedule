require 'spec_helper'

describe Account do
  
  before(:each) do
    @attr = { :name => 'Church name' }
  end
  
  it "should create a new instance" do
    Account.create! @attr
  end
  
  describe "owner" do
    it "should have an owner method" do
      owner = Factory(:user)
      account = Account.create!(:name => 'Account name', :owner_id => owner.id)
      account.should respond_to(:owner)
    end
  end
  
  describe "accountships" do
    
    before(:each) do
      @account = Account.create!(@attr)
      @user = Factory(:user)
    end
    
    it "should have an accountships method" do
      @account.should respond_to(:accountships)
    end
    
    it "should have a users method" do
      @account.should respond_to(:users)
    end
  end
  
  describe "assign_admins" do
    
    before(:each) do
      @account = Factory(:account)
      
      @signed_in_user = Factory(:user)
      @signed_in_acct = @signed_in_user.accountships.create(:account_id => @account.id, :admin => true)
      
      @owner = Factory(:user, :email => Factory.next(:email))
      @account.owner = @owner
      @account.save
      @owner_acct = @owner.accountships.create(:account_id => @account.id, :admin => true)
      
      @admin_true = Factory(:user, :email => Factory.next(:email))
      @admin_true_acct = @admin_true.accountships.create(:account_id => @account.id, :admin => true)
      @admin_false = Factory(:user, :email => Factory.next(:email))
      @admin_false_acct = @admin_false.accountships.create(:account_id => @account.id, :admin => false)
    end
    
    it "should have an assign_administrators method" do
      @account.should respond_to(:assign_administrators)
    end
    
    it "should change accountships in the passed in list to true" do
      @account.assign_administrators([@admin_true_acct.id.to_s, @admin_false_acct.id.to_s], @signed_in_user)
      Accountship.find(@admin_true_acct.id).admin.should be_true
      Accountship.find(@admin_false_acct.id).admin.should be_true
    end
    
    it "should change accountships not in the passed in list to false" do
      @account.assign_administrators([@admin_false_acct.id.to_s], @signed_in_user)
      Accountship.find(@admin_true_acct.id).admin.should_not be_true
      Accountship.find(@admin_false_acct.id).admin.should be_true
    end
    
    it "should not modify the accountship for the current_user or owner" do
      Accountship.find(@owner_acct.id).admin.should be_true
      @account.assign_administrators([@admin_true_acct.id.to_s, @admin_false_acct.id.to_s], @signed_in_user)
      Accountship.find(@signed_in_acct.id).admin.should be_true
      Accountship.find(@owner_acct.id).admin.should be_true
    end
  end
end
