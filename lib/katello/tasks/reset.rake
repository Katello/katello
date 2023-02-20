namespace :katello do
  namespace :reset_backends do
    # Switch to foreman-maintain when Pulp3 services are added to it
    service_stop = "sudo /usr/bin/systemctl status %s > /dev/null && sudo /usr/bin/systemctl stop %s"
    service_start = "sudo /usr/bin/systemctl start %s"

    task :pulp do
      SERVICES = %w(pulpcore-api pulpcore-content).freeze

      puts "\e[33mStarting Pulp3 Reset\e[0m\n\n"

      SERVICES.each { |s| system(service_stop.gsub("%s", s)) }
      system("sudo systemctl stop 'pulpcore-worker@*' --all")
      system("sudo runuser - postgres -c 'dropdb pulpcore'")
      system("sudo runuser - postgres -c 'createdb pulpcore'")
      system("sudo runuser - postgres -c \"psql -d pulpcore -c 'create extension hstore'\"")

      Dir.chdir("/tmp") do
        fail "\e[31mCannot migrate Pulp3 database\e[0m\n\n" unless system("sudo -u pulp PULP_SETTINGS='/etc/pulp/settings.py' DJANGO_SETTINGS_MODULE='pulpcore.app.settings' pulpcore-manager migrate --no-input")
        puts "\e[33mRecreating Admin User\e[0m\n\n"
        system("sudo -u pulp PULP_SETTINGS='/etc/pulp/settings.py' DJANGO_SETTINGS_MODULE='pulpcore.app.settings' pulpcore-manager reset-admin-password --password password")
      end

      SERVICES.each { |s| system(service_start.gsub("%s", s)) }
      system("sudo systemctl start 'pulpcore-worker@*' --all")
      puts "\e[32mPulp3 Database Reset Complete\e[0m\n\n"
    end

    task :candlepin do
      puts "\e[33mStarting Candlepin Reset\e[0m\n\n"

      system(service_stop.gsub("%s", 'tomcat'))
      system("sudo runuser - postgres -c 'dropdb candlepin'")
      system("sudo runuser - postgres -c 'createdb candlepin'")
      system("sudo /usr/share/candlepin/cpdb --create --schema-only")
      system("sudo /usr/share/candlepin/cpdb --update")
      system(service_start.gsub("%s", 'tomcat'))
      puts "\e[32mCandlepin Database Reset Complete\e[0m\n\n"
    end
  end

  task :reset_default_smart_proxy do
    User.current = User.anonymous_admin
    hostname = Socket.gethostname.chomp
    SmartProxy.where(name: hostname, url: "https://#{hostname}:9090").first_or_create!
  end

  desc 'Resets the Foreman/Katello development environment. WARNING: This will destroy all your Foreman, Katello and Pulp data.'
  task :reset_backends do
    Rake::Task['katello:reset_backends:candlepin'].invoke
    Rake::Task['katello:reset_backends:pulp'].invoke
  end

  task :reset => ['environment'] do
    ENV['SEED_ADMIN_PASSWORD'] ||= 'changeme'
    ENV['SEED_ORGANIZATION'] ||= 'Default Organization'
    ENV['SEED_LOCATION'] ||= 'Default Location'
    Rake::Task['katello:reset_backends'].invoke
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke

    # Otherwise migration and seeds fail because they require a reloaded environment
    system('rake db:migrate')
    system('rake db:seed')
    Rake::Task['katello:reset_default_smart_proxy'].invoke
    puts "\e[32mReset Done\e[0m\n"
  end
end
