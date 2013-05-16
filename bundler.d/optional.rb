group :optional do
  gem 'ruby-prof' if Katello.early_config.profiling && !defined?(JRUBY_VERSION)
end
