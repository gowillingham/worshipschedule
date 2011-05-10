Factory.sequence :email do |n|
  "example#{n}@example.com"
end

Factory.define :team do |team|
  team.name 'Team name'
end

Factory.define :account do |account|
  account.name 'Church name'
  account.after_create { |a| Factory(:team, :name => 'Team 1', :account => a) }
  account.after_create { |a| Factory(:team, :name => 'Team 2', :account => a) }
end

Factory.define :user do |user|
  user.first_name 'Stephen'
  user.last_name 'Willingham'
  user.password 'password'
  user.password_confirmation 'password'
  user.email { Factory.next(:email) }
end

