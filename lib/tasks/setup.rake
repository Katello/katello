desc "check if not running as root with sqlite3 in production mode (creates wrong permissions)"
require 'util/db_setup_check'
task :check_db_config => "db:load_config" do
  Katello::DbSetupCheck.check!
end

task :clear_search_indices do
  Tire.index("_all").delete
  puts "Search Indices cleared."
end

desc "executes db:seed but with rails logging on the STDOUT"
task :seed_with_logging => ["db:seed"] do
  if defined?(Rails)
    Rails.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger = Logger.new("#{Rails.root}/log/setup_sql.log")
  end
end

desc "task to perform steps required for katello to work"
task :setup => ['environment', "check_db_config", "clear_search_indices", "db:migrate:reset", "seed_with_logging"] do
  puts "Database sucessfully recreated in #{Rails.env}"
end
