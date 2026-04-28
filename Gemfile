source 'https://rubygems.org'

gemspec

Dir[File.join(__dir__, 'gemfile.d', '*.rb')].each do |bundle|
  eval_gemfile(bundle)
end

gem 'theforeman-rubocop', '~> 0.1.2', require: false, groups: %i[development rubocop]
