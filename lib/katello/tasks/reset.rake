namespace :katello do
  namespace :reset_backends do
    service_stop = "sudo /usr/bin/systemctl status %s > /dev/null && sudo /usr/bin/systemctl stop %s"
    service_start = "sudo /usr/bin/systemctl start %s"

    task :pulp_legacy do
      SERVICES = %w(httpd pulp_workers pulp_resource_manager pulp_celerybeat squid qpidd pulp_streamer).freeze

      SERVICES.each { |s| system(service_stop.gsub("%s", s)) }
      system(service_start.gsub("%s", rh-mongodb34-mongod))
      system("mongo pulp_database --eval 'db.dropDatabase();'")
      fail 'Cannot migrate Pulp database' unless system('sudo -u apache /usr/bin/pulp-manage-db')

      SERVICES.each { |s| system(service_start.gsub("%s", s)) }
      puts 'Pulp2 database reset.'
      end
    end

    task: pulp do
      PULP_DIR = '/usr/local/lib/pulp/bin'

      # Pull active workers from redis to see how many we need to start up
      worker_count = `redis-cli --scan --pattern "rq:workers:reserved-resource-worker*" | wc -l`.chomp.to_i

      services = %w(redis pulpcore-api pulpcore-resource-manager pulpcore-content)
      while worker_count > 0 do
        services.push("pulpcore-worker@#{worker_count}")
        worker_count = worker_count - 1
      end

      services.each { |s| system(service_stop.gsub("%s", s)) }
      system("runuser - postgres -c 'dropdb pulp -p 7878'")
      fail 'Cannot migrate Pulp database' unless system("#{PULP_DIR}/django-admin migrate auth --no-input")
      fail 'Cannot migrate Pulp database' unless system("#{PULP_DIR}/django-admin migrate --no-input")

      services.each { |s| system(service_start.gsub("%s", s)) }
      puts 'Pulp3 database reset.'
    end

    task :candlepin do

      system(service_stop.gsub("%s", tomcat))
      system('sudo /usr/share/candlepin/cpdb --drop --create')
      system(service_start.gsub("%s", tomcat))
      puts 'Candlepin database reset.'
    end
  end

  task :reset_default_smart_proxy do
    User.current = User.anonymous_admin
    hostname = Socket.gethostname.chomp
    SmartProxy.where(name: hostname, url: "https://#{hostname}:9090").first_or_create!
  end

  desc 'Resets the Foreman/Katello development environemnt. WARNING: This will destroy all your Foreman, Katello and Pulp data.'
  task :reset_backends do
    Rake::Task['katello:reset_backends:candlepin'].invoke
    if File.exists?('/usr/local/lib/pulp/bin') # When Pulp2 is no longer on nightly we will need to change this
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
  end
end
