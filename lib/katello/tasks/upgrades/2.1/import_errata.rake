namespace :katello do
  namespace :upgrades do
    namespace '2.1' do
      task :import_errata => ["environment"]  do

        def error(exception)
          message = _("There was an error updating Content Host %{name} with id %{id}") %
                               {:name =>system.name, :id => system.id}
          puts message
          Rails.logger.error(message)
          Rails.logger.error(e.message)
        end

        def update_system_repositories(system)
          if system.bound_repositories.empty?
            puts _("Updating Content Host Repositories %s") % system.name
            system.bound_repositories << Katello::Repository.where(:pulp_id => system.pulp_bound_yum_repositories)
            system.save!
            system.propagate_yum_repos
          end
        end


        User.current = User.anonymous_api_admin

        puts _("Importing Errata")
        Katello::Erratum.import_all

        Katello::System.find_each do |system|
          begin
            update_system_repositories(system)
          rescue => e
            error(e)
          end
        end

        if Katello::System.any?
          puts _("Generating applicability for %s Content Hosts") % Katello::System.count
          ForemanTasks.sync_task(::Actions::Katello::System::GenerateApplicability,
                                 Katello::System.select([:id, :uuid]).all)
        end
      end
    end
  end
end
