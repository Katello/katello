group :development do
  # <test gems> that are here to make things (rake) easier
  gem 'rspec-rails', '~> 2.13.2'
  gem "parallel_tests"
  # </test gems>

  # code documentation
  gem 'yard', '>= 0.5.3'

  # Enable to have attributes and associations of ActiveRecord documented
  gem 'yard-activerecord'

  # Enable to be able to generate graphs
  # gem 'railroady'

  # generates routes in javascript
  gem "js-routes", '~> 0.9.0', :require => 'js_routes'

  # for generating i18n files
  gem 'gettext', '>= 1.9.3', :require => false
  # for gettext in haml support
  gem 'ruby_parser'
  gem 'sexp_processor'

  gem 'minitest-rails'

  gem 'factory_girl_rails', "~> 1.4.0"
end
