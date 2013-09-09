group :test do
  # (also appears in development group)
  gem 'rspec-rails', '~> 2.13.2'

  gem 'webrat', '>=0.7.3'
  gem 'nokogiri', '>= 1.5.0'

  gem 'vcr'
  gem 'webmock'
  gem 'minitest', '<=4.5.0', :require => "hoe/minitest"
  gem 'minitest-rails'

  gem 'mocha', '~> 0.13.1', :require => false
  # make our specs go faster (also appears in development group)
  gem "parallel_tests"
end
