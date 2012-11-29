group :development do
  # code documentation
  gem 'yard', '>= 0.5.3'
  gem 'rspec-rails', '>= 2.0.0' # to be able to run rake spec form development environment
  # for apipie generation

  # generates routes in javascript
  gem "js-routes", :require => 'js_routes'

  # for generating i18n files - TODO do we need ruby_parser here?
  gem 'gettext', '>= 1.9.3', :require => false
    gem 'ruby_parser'
      gem 'sexp_processor'
end
