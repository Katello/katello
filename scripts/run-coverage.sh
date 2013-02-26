#!/usr/bin/env ruby

Dir.chdir(File.join(Dir.pwd, "src/"))
system("bundle install")
system("RAILS_ENV=test rake db:migrate:reset --trace")

if RUBY_VERSION >= "1.9"
  system("rake simplecov")
else
  # TODO: does this aggregate minitest and rspec coverage?
  system("RAILS_ENV=test rake rcov SPEC_OPTS='-p' --trace")
end
