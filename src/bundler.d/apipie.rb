group :apipie do
  # apipie itself is in default
  unless defined? JRUBY_VERSION
    gem 'redcarpet'
  end
end

