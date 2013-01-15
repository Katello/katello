namespace "ptest" do

  desc "Run parallel spec tests for headpin or katello, depending on 'app_mode' in katello.yml"
  task :spec, :pattern, :threads do |_, args|

    tags = {"headpin" => "~katello", "katello" => "~headpin"}

    mode = Katello.config.app_mode
    puts "testing in #{mode} mode. change 'app_mode' in config/katello.yml."
    tests("/#{mode}", args, tags[mode])
  end

  def tests(env, task_args, rspec_args)
    task_args.with_defaults(:pattern => '\'\'', :threads => 4)

    pattern_search = task_args[:pattern] != '\'\''

    rspec_options = "--tag \"#{rspec_args}\""
    rspec_options << " -fd" if pattern_search

    cpus = (pattern_search) ? 1 : task_args[:threads]

    Rake::Task["parallel:spec"].invoke(cpus, task_args[:pattern], rspec_options)
  end

end
