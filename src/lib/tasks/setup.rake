desc "check if not running as root with sqlite3 in production mode (creates wrong permissions)"
require 'util/db_setup_check'
task :check_db_config => "db:load_config" do
  Katello::DbSetupCheck.check!
end

task :clear_search_indices do
  Tire.index("_all").delete
  puts "Search Indices cleared."
end


desc "task to perform steps required for katello to work"
task :setup => ["check_db_config", "clear_search_indices", "db:migrate:reset", "db:seed"] do
  puts "Database sucessfully recreated in #{Rails.env}"
end
