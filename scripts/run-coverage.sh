#!/usr/bin/env ruby

def run_command(cmd)
  puts "Running #{cmd}"
  unless system(cmd)
    STDERR.puts("Failed")
    exit 1
  end
end

Dir.chdir(File.join(Dir.pwd, "src/"))
run_command("bundle install")
run_command("rake db:test:load --trace")

if RUBY_VERSION >= "1.9"
  run_command("rake simplecov")
else
  # TODO: does this aggregate minitest and rspec coverage?
  run_command("RAILS_ENV=test rake rcov SPEC_OPTS='-p' --trace")
end
