if RUBY_VERSION >= "1.9"
  require 'simplecov'

  task :simplecov do
    ENV['COVERAGE'] = 'true'
    Rake::Task["minitest"].execute
    Rake::Task["spec"].execute
  end
end
