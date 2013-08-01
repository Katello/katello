group :development do
  # <test gems> that are here to make things (rake) easier
    #gem "parallel_tests"
  # </test gems>

  # for gettext in haml support
  gem 'ruby_parser'
  gem 'sexp_processor'

  gem 'minitest-rails'

  gem 'factory_girl_rails', "~> 1.4.0"
end
