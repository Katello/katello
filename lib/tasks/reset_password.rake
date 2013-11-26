namespace :katello do
  desc 'Reset Administrator password'
  task :reset_password => [:environment] do
    user = User.find_by_username("admin")
    User.current = user
    user.password="changeme"
    if user.save!
      puts "Reset admin user to password:changeme"
    else
      puts user.errors.full_messages.join(", ")
    end
  end
end

