namespace :db do
  desc "Fill the database with test data"
  task :populate => :environment do
    require 'populator'
    require 'faker'

    # [UserGroup, User, Order].each(&:delete_all)

      User.populate 200 do |user|
        user.name           = Faker::Name.first_name
        user.login          ="#{user.name}" + "#{user.id}"
#        user.login          = Populator.words(1)
        user.email          = "#{user.name.downcase}@#{Faker::Internet.domain_name}"
        user.crypted_password = '3854b51fa0fe317e3b83c9c024f0722a59dddb77'
        user.salt           = '5087aacc106e9391b25adfe1248c3f0b53ecf4f2'
        user.state          = ['passive', 'pending', 'suspended']
        user.created_at     = 2.years.ago..Time.now
      end
  end
end
