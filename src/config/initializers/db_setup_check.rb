if (db_config = Katello.database_configs[Rails.env]) && db_config['adapter'] == 'sqlite3'
  Rails.logger.warn 'SQLite3 is not supported. It will probably not work.'
  Rails.logger.error 'Running in production on SQLite3 is HIGHLY discouraged!' if Rails.env.production?
end
