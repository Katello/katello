require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs Rubocop style checker on Katello code"
  task :rubocop do
    system("bundle exec rubocop #{Katello::Engine.root}")
    exit($CHILD_STATUS.exitstatus)
  end

  desc "Runs Rubocop style checker with xml output for Jenkins"
  task 'rubocop:jenkins' do
    system("bundle exec rubocop #{Katello::Engine.root} \
            --require rubocop/formatter/checkstyle_formatter \
            --format RuboCop::Formatter::CheckstyleFormatter \
            --no-color --out rubocop.xml")
    exit($CHILD_STATUS.exitstatus)
  end
end
