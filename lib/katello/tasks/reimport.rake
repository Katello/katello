require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs a katello ping and prints out the statuses of each service"
  task :check_ping => :environment do
    ::User.current = ::User.anonymous_admin
    RETRIES = 3
    RETRY_INTERVAL = 2
    RETRIES.times do |retry_count|
      ping_results = Katello::Ping.ping

      if ping_results[:status] != "ok"
        pp ping_results
        services = ping_results[:services]
        if services.value?({:status => "FAIL", :message => "503 Service Unavailable"}) &&
            retry_count < (RETRIES - 1)
          pp "Services unavailable - retrying..."
          sleep RETRY_INTERVAL
        else
          fail("Not all the services have been started. Check the status report above and try again.")
        end
      end
    end
  end

  desc "Reimports information from backend systems"
  task :reimport => ["dynflow:client", "katello:check_ping"] do
    User.current = User.anonymous_admin #set a user for orchestration
    Dir.glob(Katello::Engine.root.to_s + '/app/models/katello/*.rb').each { |file| require file }

    models = [
      Katello::Subscription,
      Katello::Pool,
      Katello::ContentViewPuppetEnvironment,
      Katello::Content
    ]

    Katello::RepositoryTypeManager.repository_types.each_value do |repo_type|
      indexable_types = repo_type.content_types_to_index
      if SmartProxy.pulp_primary.pulp3_repository_type_support?(repo_type)
        puts "\e[33mIgnoring types: #{indexable_types&.map { |type| type.model_class.name }}\e[0m\n"
      else
        models += indexable_types&.map(&:model_class)
      end
    end

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
