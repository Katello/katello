#check if not running as root in production mode (creates wrong permissions)
raise 'You cannot run "rake setup" as root in production mode' if Process.uid == 0 and Rails.env == 'production'

#task to perform steps required for katello to work
task :setup => ["db:migrate:reset", "db:seed"] do
  puts "Database sucessfully recreated in #{Rails.env}"
end
