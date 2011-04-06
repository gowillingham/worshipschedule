Factory.sequence :email do |n|
  "example#{n}@example.com"
end

Factory.define :user do |user|
  user.first_name 'Stephen'
  user.last_name 'Willingham'
  user.password 'password'
  user.password_confirmation 'password'
  user.email { Factory.next(:email) }
end
