task :clear_search_indices do
  Tire.index("_all").delete
  puts "Search Indices cleared."
end

desc "executes db:seed but with rails logging on the STDOUT"
task :seed_with_logging => ["db:seed"] do
  if defined?(Rails)
    Rails.logger = Logging.logger.root.add_appenders(Logging.appenders.stdout)
    sql_logger = Logging.logger['setup_sql']
    sql_logger.add_appenders(Logging.appenders.file("#{Rails.root}/log/setup_sql.log"))
    sql_logger.additive = false # set to true if you want to see log also on STDOUT
    ActiveRecord::Base.logger = sql_logger
  end
end

desc "task to perform steps required for katello to work"
task :setup => ['environment', "clear_search_indices", "db:migrate:reset", "seed_with_logging"] do
  puts "Database sucessfully recreated in #{Rails.env}"
end
