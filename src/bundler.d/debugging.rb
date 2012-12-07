group :debugging do
  if RUBY_VERSION >= "1.9.2" and ! defined? JRUBY_VERSION
    gem 'debugger'
  elsif RUBY_VERSION == "1.9.1" and ! defined? JRUBY_VERSION
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
end
