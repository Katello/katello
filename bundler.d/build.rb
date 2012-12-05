group :build do
  unless defined? JRUBY_VERSION
    # for apipie (it is in default group)
    gem 'redcarpet'
  end
end

