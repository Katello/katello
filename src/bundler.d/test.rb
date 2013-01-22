group :test do
  gem 'ZenTest', '>= 4.4.0', :require => "autotest"
  gem 'autotest-rails', '>= 4.1.0'

  # (also appears in development group)
  gem 'rspec-rails', '>= 2.0.0'

  # TODO - it looks we do not have any webrat tests
  gem 'webrat', '>=0.7.3'
    gem 'nokogiri', '>= 1.5.0'

  gem 'vcr'
  gem 'webmock'
  gem 'minitest', :require => "hoe/minitest"

  # make our specs go faster (also appears in development group)
  gem "parallel_tests"
end
