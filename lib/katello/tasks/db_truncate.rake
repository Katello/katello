namespace :db do
  desc "Truncate all existing data"
  task :truncate => "db:load_config" do
   begin
    config = ActiveRecord::Base.configurations[::Rails.env]
    ActiveRecord::Base.establish_connection
    case config["adapter"]
      when "mysql", "postgresql"
        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.tables.reject{|x| x == 'schema_migrations'}.each do |table|
            ActiveRecord::Base.connection.execute("TRUNCATE #{table}")
          end
        end
      when "sqlite", "sqlite3"
        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection.tables.reject{|x| x == 'schema_migrations'}.each do |table|
            ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
            ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence where name='#{table}'")
          end
        end
       ActiveRecord::Base.connection.execute("VACUUM")
     end
    end
  end
end
