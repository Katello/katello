group :debugging do
  if ! defined? JRUBY_VERSION
    gem 'debugger'
  else
    gem 'ruby-debug'
  end
end
