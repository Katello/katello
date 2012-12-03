group :profiling do
  unless defined? JRUBY_VERSION
    gem 'ruby-prof'
    gem 'logical-insight'
  end
  gem 'newrelic_rpm'
end
