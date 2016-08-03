namespace :katello do
  desc "Runs a katello ping and prints out the statuses of each service"
  task :check_ping do
    User.current = User.anonymous_admin
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
              Katello::Subscription,
              Katello::Pool]

    models << Katello::OstreeBranch if Katello::RepositoryTypeManager.find(Katello::Repository::OSTREE_TYPE).present?

    models.each do |model|
      print "Importing #{model.name}\n"
      model.import_all
    end

    print "Importing Activation Key Subscriptions\n"
    Katello::ActivationKey.all.each do |ack_key|
      ack_key.import_pools
    end

    print "Importing Docker Content\n"
    # For docker repositories, index all associated manifests and tags
    Katello::Repository.docker_type.each do |docker_repo|
      docker_repo.index_db_docker_manifests
    end
  end
end
