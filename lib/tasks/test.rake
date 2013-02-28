namespace "ptest" do

  desc "Run parallel spec tests for headpin or katello, depending on 'app_mode' in katello.yml"
  task :spec, :pattern, :threads do |_, args|

    tags = {"headpin" => "~katello", "katello" => "~headpin"}

    mode = Katello.config.app_mode
    puts "testing in #{mode} mode. change 'app_mode' in config/katello.yml."
    tests("/#{mode}", args, tags[mode])
  end

  def tests(env, task_args, rspec_args)
    task_args.with_defaults(:pattern => '\'\'', :threads => 0)

    pattern_search = task_args[:pattern] != '\'\''

    rspec_options = "--tag \"#{rspec_args}\""
    rspec_options << " -fd" if pattern_search

    cpus = (pattern_search) ? 1 : task_args[:threads]

    Rake::Task["parallel:spec"].invoke(cpus, task_args[:pattern], rspec_options)
  end

end


if ENV['method']
  if not ENV['method'].starts_with?('test_')
    ENV['method'] = "test_#{ENV['method']}"
  end

  if ENV['TESTOPTS']
    ENV['TESTOPTS'] += "--name=#{ENV['method']}"
  else
    ENV['TESTOPTS'] = "--name=#{ENV['method']}"
  end
end

MINITEST_TASKS  = %w(models helpers controllers glue lib)
GLUE_LAYERS     = %w(pulp candlepin elasticsearch)

Rake::Task["minitest"].clear
Rake::Task["minitest:models"].clear

desc 'Runs all minitest tests'
MiniTest::Rails::Tasks::SubTestTask.new(:minitest) do |t|
  t.libs.push 'test'
  t.pattern = "test/#{task}/**/*_test.rb"
end

namespace 'minitest' do
  Rake::Task["db:test:prepare"].clear

  MINITEST_TASKS.each do |task|
    if ENV['test']
      #Rake::Task["minitest:models"].clear
      Rake::Task["db:test:prepare"].clear
      MiniTest::Rails::Tasks::SubTestTask.new(task => 'test:prepare') do |t|
        t.libs.push 'test'
        t.pattern = "test/#{task}/#{ENV['test']}_test.rb"
      end
    else
      desc "Runs the #{task} tests"

      MiniTest::Rails::Tasks::SubTestTask.new(task => 'test:prepare') do |t|
        t.libs.push 'test'
        t.pattern = "test/#{task}/**/*_test.rb"
      end
    end
  end

  namespace :glue do

    GLUE_LAYERS.each do |task|

      desc "Finds functions without dedicated tests"
      task "#{task}:untested" do
        test_functions  = `grep -r 'def test_' test/glue/#{task} --include=*.rb --no-filename` 
        lib_functions   = `grep -r 'def self' app/models/glue/#{task} --include=*.rb --no-filename`
        
        test_functions  = test_functions.split("\n").map{ |str| str.strip.split("def test_")[1] }.to_set
        lib_functions   = lib_functions.split("\n").map{ |str| str.strip.split("def ")[1].split("(").first }.to_set

        difference = (lib_functions - test_functions).to_a

        if !difference.empty?
          puts difference
          exit 1 
        end
      end

      if ENV['test']
        MiniTest::Rails::Tasks::SubTestTask.new(task => 'test:prepare') do |t|
          t.libs.push 'test'
          t.pattern = "test/glue/#{task}/#{ENV['test']}_test.rb"
        end   
      else
        desc "Runs the #{task} glue layer tests"

        MiniTest::Rails::Tasks::SubTestTask.new(task => 'test:prepare') do |t|
          t.libs.push 'test'
          t.pattern = "test/glue/#{task}/**/*_test.rb"
        end
      end
    end

  end

end
