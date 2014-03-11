namespace :katello do

  namespace :reset_backends do
    service_stop = "sudo /sbin/service %s status > /dev/null && sudo /sbin/service %s stop"
    service_start = "sudo /sbin/service %s start"

    task :pulp do
      system(service_stop.gsub("%s", "mongod"))
      system(service_stop.gsub("%s", "qpidd"))
      system(service_stop.gsub("%s", "httpd"))
      system("sudo rm -rf /var/lib/mongodb/pulp_database*")
      system(service_start.gsub("%s", "mongod"))
      sleep(10)
      system("sudo /usr/bin/pulp-manage-db")
      system(service_start.gsub("%s", "qpidd"))
      system(service_start.gsub("%s", "httpd"))
      puts "Pulp database reset."
    end

    task :candlepin do
      tomcat = File.exists?('/var/lib/tomcat') ? 'tomcat' : 'tomcat6'

      system(service_stop.gsub("%s", tomcat))
      system("sudo /usr/share/candlepin/cpdb --drop --create")
      # If you see errors with 'javax.crypto.BadPaddingException: Given final block not properly padded'
      # it is due to a candlepin dev setup with a different password on the keystre
      # than in this file.
      system("sudo /usr/share/candlepin/cpsetup -s -k `sudo cat /etc/katello/keystore_password-file`")
      puts "Candlepin database reset."
    end

    task :elasticsearch => ['environment'] do
      Dir.glob(Katello::Engine.root.to_s + '/app/models/katello/*.rb').each { |file| require file }

      Katello::Util::Search.active_record_search_classes.each do |model|
        Tire.index(model.index.name).delete
      end

      Tire.index(Katello::Package.index).delete
      Tire.index(Katello::Errata.index).delete
      Tire.index(Katello::PackageGroup.index).delete
      Tire.index(Katello::PuppetModule.index).delete
      Tire.index(Katello::Pool.index).delete
      puts "Elasticsearch Indices cleared."
    end
  end

  desc "Resets Foreman/Katello development environemnt. WARNING: This will destroy all your Foreman and Katello data."
  task :reset_backends do
    Rake::Task['katello:reset_backends:candlepin'].invoke
    Rake::Task['katello:reset_backends:pulp'].invoke
  end

  task :reset => ['environment'] do
    Rake::Task['katello:reset_backends'].invoke
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke

    # Otherwise migration fails since it currently requires a reloaded environment
    system('rake db:migrate')

    Rake::Task['katello:reset_backends:elasticsearch'].invoke
    # Load configuration needed by db:seed first
    require './config/initializers/foreman.rb'
    Rake::Task['db:seed'].invoke
  end
end
