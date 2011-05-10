require 'faker'

namespace:db do
  desc "Fill database with sample data"
  task :populate => :environment do
    
    Rake::Task['db:reset'].invoke
    
    account = Account.create!(
      :name => "Hosanna LC"
    )
    
    admin = User.create!(
      :first_name => "Stephen",
      :last_name => "Willingham",
      :email => "gowillingham@gmail.com",
      :password => "password",
      :password_confirmation => "password"
      )
    admin.accountships.create(:account_id => account.id, :admin => true)
    
    account.owner = admin
    account.save
    
    team_one = Team.create!(
      :name => 'Worship team',
      :account_id => account.id
    )
    team_two = Team.create!(
      :name => 'Technical arts',
      :account_id => account.id
    )
    team_three = Team.create!(
      :name => "Children's ministries",
      :account_id => account.id
    )    
    
    5.times do |n|
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      email = "admin-email-#{n+1}@longdomainhere.org"
      password = "password"
      user = User.create!(
        :first_name => first_name,
        :last_name => last_name,
        :email => email,
        :password => "password",
        :password_confirmation => "password"
      )
      user.accountships.create(:account_id => account.id, :admin => true)
    end
    
    99.times do |n|
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      email = "email-#{n+1}@longdomainhere.org"
      password = "password"
      user = User.create!(
        :first_name => first_name,
        :last_name => last_name,
        :email => email,
        :password => "password",
        :password_confirmation => "password"
      )
      user.accounts << account
    end
  end
end
