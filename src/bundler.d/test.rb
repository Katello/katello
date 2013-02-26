group :test do
  # NOTE: ZenTest-4.8.4 contains a spec parsing error
  gem 'ZenTest', '>= 4.4.0', '< 4.8.4', :require => "autotest"
  gem 'autotest-rails', '>= 4.1.0'

  # (also appears in development group)
  gem 'rspec-rails', '>= 2.0.0'

  # TODO - it looks we do not have any webrat tests
  gem 'webrat', '>=0.7.3'
  gem 'nokogiri', '>= 1.5.0'

  gem 'vcr'
  gem 'webmock'
  gem 'minitest', '<=4.5.0', :require => "hoe/minitest"
  gem 'minitest-rails'
  gem 'mocha', :require=>false
  # make our specs go faster (also appears in development group)
  gem "parallel_tests"
end
