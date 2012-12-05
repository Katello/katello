group :debugging do
  if RUBY_VERSION >= "1.9.2"
    gem 'debugger'
  elsif RUBY_VERSION == "1.9.1"
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
end
