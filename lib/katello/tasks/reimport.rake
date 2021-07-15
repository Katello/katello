require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs a katello ping and prints out the statuses of each service"
  task :check_ping => [:environment, "dynflow:client"] do
    ::User.current = ::User.anonymous_admin
    ping_results = Katello::Ping.ping
    if ping_results[:status] != "ok"
      pp ping_results
      fail("Not all the services have been started. Check the status report above and try again.")
    end
  end

  desc "Reimports information from backend systems"
  task :reimport => ["dynflow:client", "katello:check_ping"] do
    User.current = User.anonymous_admin #set a user for orchestration
    Dir.glob(Katello::Engine.root.to_s + '/app/models/katello/*.rb').each { |file| require file }

    models = [
      Katello::Subscription,
      Katello::Pool,
      Katello::Content
    ]

    models.each do |model|
      print "Importing #{model.name}\n"
      model.import_all
    end

    print "Importing Activation Key Subscriptions\n"
    Katello::ActivationKey.all.each do |ack_key|
      ack_key.import_pools
    end

    print "Importing Linked Repositories"
    Katello::Repository.linked_repositories.each(&:index_content)
  end
end
