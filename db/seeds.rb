User.create!(name:  "Admin User",
             email: "admin@email.com",
             password:              "adminpassword",
             password_confirmation: "adminpassword",
             admin: true)

10.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@testemail.se"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end