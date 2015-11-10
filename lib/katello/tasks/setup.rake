namespace :katello do

  namespace :reset_backends do
    service_stop = "sudo /sbin/service %s status > /dev/null && sudo /sbin/service %s stop"
    service_start = "sudo /sbin/service %s start"

    task :pulp do
      SERVICES = %w(httpd pulp_workers pulp_resource_manager pulp_celerybeat)
      system(service_stop.gsub("%s", "mongod"))

      SERVICES.each{|s| system(service_stop.gsub("%s", s)) }
      system("sudo rm -rf /var/lib/mongodb/pulp_database*")
      system(service_start.gsub("%s", "mongod"))
      sleep(10)
      fail "Cannot migrate pulp database" unless system("sudo -u apache /usr/bin/pulp-manage-db")
      SERVICES.each{|s| system(service_start.gsub("%s", s)) }
      puts "Pulp database reset."
    end

    task :candlepin do
      tomcat = File.exist?('/var/lib/tomcat') ? 'tomcat' : 'tomcat6'

      system(service_stop.gsub("%s", tomcat))
      system("sudo /usr/share/candlepin/cpdb --drop --create")
      system(service_start.gsub("%s", tomcat))
      puts "Candlepin database reset."
    end
  end

  desc "Resets Foreman/Katello development environemnt. WARNING: This will destroy all your Foreman and Katello data."
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

    # Otherwise migration fails since it currently requires a reloaded environment
    system('rake db:migrate')

    # Load configuration needed by db:seed first
    require './config/initializers/foreman.rb'
    Rake::Task['db:seed'].invoke
  end
end
