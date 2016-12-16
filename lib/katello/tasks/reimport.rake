require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs a katello ping and prints out the statuses of each service"
  task :check_ping => :environment do
    ::User.current = ::User.anonymous_admin
    ping_results = Katello::Ping.ping
    if ping_results[:status] != "ok"
      pp ping_results
      fail("Not all the services have been started. Check the status report above and try again.")
    end
  end

  desc "Reimports information from backend systems"
  task :reimport => ["environment", "katello:check_ping"] do
    User.current = User.anonymous_admin #set a user for orchestration

    Dir.glob(Katello::Engine.root.to_s + '/app/models/katello/*.rb').each { |file| require file }

    models = [Katello::Erratum,
              Katello::PackageGroup,
              Katello::PuppetModule,
              Katello::Rpm,
              Katello::FileUnit,
              Katello::Subscription,
              Katello::Pool,
              Katello::DockerManifest,
              Katello::DockerTag]

    models << Katello::OstreeBranch if Katello::RepositoryTypeManager.find(Katello::Repository::OSTREE_TYPE).present?

    models.each do |model|
      print "Importing #{model.name}\n"
      model.import_all
    end

    print "Importing Activation Key Subscriptions\n"
    Katello::ActivationKey.all.each do |ack_key|
      ack_key.import_pools
    end
  end
end
