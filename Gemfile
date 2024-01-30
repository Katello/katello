source 'https://rubygems.org'

gemspec

Dir[File.join(__dir__, 'gemfile.d', '*.rb')].each do |bundle|
  eval_gemfile(bundle)
end

gem 'dynflow', git: 'https://github.com/adamruzicka/dynflow', branch: 'kwargs-extravaganza'
