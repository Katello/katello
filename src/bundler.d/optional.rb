group :optional do
  unless defined? JRUBY_VERSION
    gem 'ruby-prof'
  end
  gem 'newrelic_rpm'
end
