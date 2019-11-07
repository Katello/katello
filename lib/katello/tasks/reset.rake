namespace :katello do
  namespace :reset_backends do
    # Switch to foreman-maintain when Pulp3 services are added to it
    service_stop = "sudo /usr/bin/systemctl status %s > /dev/null && sudo /usr/bin/systemctl stop %s"
    service_start = "sudo /usr/bin/systemctl start %s"

    task :pulp_legacy do
      SERVICES = %w(httpd pulp_workers pulp_resource_manager pulp_celerybeat squid qpidd pulp_streamer).freeze

      puts "\e[33mStarting Pulp2 Reset\e[0m\n\n"

      SERVICES.each { |s| system(service_stop.gsub("%s", s)) }
      system(service_start.gsub("%s", 'rh-mongodb34-mongod'))
      system("mongo pulp_database --eval 'db.dropDatabase();'")
      fail "\e[31mCannot Migrate Pulp2 Database\e[0m\n\n" unless system('sudo -u apache /usr/bin/pulp-manage-db')

      SERVICES.each { |s| system(service_start.gsub("%s", s)) }
      puts "\e[32mPulp2 Database Reset Complete\e[0m\n\n"
    end

    task :pulp do
      SERVICES = %w(redis pulpcore-api pulpcore-resource-manager pulpcore-content).freeze

      puts "\e[33mStarting Pulp3 Reset\e[0m\n\n"

      SERVICES.each { |s| system(service_stop.gsub("%s", s)) }
      system("sudo systemctl stop 'pulpcore-worker@*' --all")
      system("sudo runuser - postgres -c 'dropdb pulp -p 7878'")
      system("sudo runuser - postgres -c 'createdb pulp -p 7878'")
      Dir.chdir('/usr/local/lib/pulp/bin') do
        fail "\e[31mCannot migrate Pulp3 database\e[0m\n\n" unless system("sudo -u pulp PULP_SETTINGS='/etc/pulp/settings.py' DJANGO_SETTINGS_MODULE='pulpcore.app.settings' ./django-admin migrate --no-input")
        puts "\e[33mRecreating Admin User\e[0m\n\n"
        system("sudo -u pulp PULP_SETTINGS='/etc/pulp/settings.py' DJANGO_SETTINGS_MODULE='pulpcore.app.settings' ./django-admin reset-admin-password --password password")
      end

      SERVICES.each { |s| system(service_start.gsub("%s", s)) }
      system("sudo systemctl start 'pulpcore-worker@*' --all")
      puts "\e[32mPulp3 Database Reset Complete\e[0m\n\n"
    end

    task :candlepin do
      puts "\e[33mStarting Candlepin Reset\e[0m\n\n"

      system(service_stop.gsub("%s", 'tomcat'))
      system('sudo /usr/share/candlepin/cpdb --drop --create')
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
    if File.exist?('/usr/local/lib/pulp/bin') # When Pulp2 is no longer on nightly we will need to change this
      Rake::Task['katello:reset_backends:pulp'].invoke
      Rake::Task['katello:reset_backends:pulp_legacy'].invoke
    else
      Rake::Task['katello:reset_backends:pulp_legacy'].invoke
    end
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
