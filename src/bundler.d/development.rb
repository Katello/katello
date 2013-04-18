group :development do
  # <test gems> that are here to make things (rake) easier
    gem 'rspec-rails', '>= 2.0.0'
    gem "parallel_tests", "~> 0.10.1"
  # </test gems>

  # code documentation
  gem 'yard', '>= 0.5.3'

  # Enable to have attributes and associations of ActiveRecord documented
  # gem 'yard-activerecord', :git => 'git://github.com/pitr-ch/yard-activerecord.git'

  # Enable to be able to generate graphs
  # gem 'railroady'

  # generates routes in javascript
  gem "js-routes", '~> 0.6.2', :require => 'js_routes'

  # for generating i18n files
  gem 'gettext', '>= 1.9.3', :require => false
  # for gettext in haml support
  gem 'ruby_parser'
  gem 'sexp_processor'

  gem 'minitest-rails'

  gem 'factory_girl_rails', "~> 1.4.0"
end
