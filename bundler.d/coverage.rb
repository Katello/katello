group :coverage do
  if RUBY_VERSION >= "1.9.2"
    gem 'simplecov'
  else
    gem 'rcov', '>= 0.9.9'
  end
end

