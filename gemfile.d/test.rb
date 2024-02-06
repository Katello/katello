group :test do
  gem "vcr", "~> 6.1"
  gem 'theforeman-rubocop', '~> 0.0.6', require: false
  # TODO: Remove it, just to test the changes.
  gem 'foreman-tasks', git: 'https://github.com/ofedoren/foreman-tasks.git', branch: 'feat-37103-kwargs-compat'
end
