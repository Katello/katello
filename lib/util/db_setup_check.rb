module Katello
  class DbSetupCheck
    # Ensures sqlite is not used as a database engine. It's not supported
    # by the Katello project.
    def self.check!
      if ActiveRecord::Base.configurations[Rails.env] and
          ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'sqlite3' and
          not ENV['FORCE_DB_SETUP']
        raise 'SQLite3 is not supported. If you still want to use this adapeter, set FORCE_DB_SETUP=true.'
      end
    end
  end
end
