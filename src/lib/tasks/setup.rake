#task to perform steps required for katello to work
task :setup => ["db:migrate:reset", "db:seed"] do
  puts "Database sucessfully recreated in #{Rails.env}"
end
