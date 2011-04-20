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
