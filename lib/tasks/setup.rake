#check if not running as root with sqlite3 in production mode (creates wrong permissions)
raise 'SQLite3 is not supported in production mode! You can still run "rake setup" as katello user.' if Process.uid == 0 
  and Rails.env == 'production' 
  and ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'sqlite3'
  and and not ENV['FORCE_RAKE_SETUP']

#task to perform steps required for katello to work
task :setup => ["db:migrate:reset", "db:seed"] do
  puts "Database sucessfully recreated in #{Rails.env}"
end
