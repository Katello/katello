namespace :katello do
  namespace :upgrades do
    namespace '2.1' do
      task :import_errata => ["environment"]  do

        def error(exception, host)
          message = _("There was an error updating Content Host %{name} with id %{id}") %
                               {:name =>host.name, :id => host.id}
          puts message
          Rails.logger.error(message)
          Rails.logger.error(exception.message)
        end

        def update_host_repositories(host)
          if host.content_facet.present? and host.content_facet.bound_repositories.empty?
            puts _("Updating Content Host Repositories %s") % host.name
            pulp_ids = host.content_facet.bound_repositories.includes(:library_instance).map { |repo| repo.library_instance.try(:pulp_id) || repo.pulp_id }
            host.content_facet.bound_repositories << Katello::Repository.where(:pulp_id => pulp_ids)
            host.content_facet.save!
            host.content_facet.propagate_yum_repos unless pulp_ids.empty?
          end
        end


        User.current = User.anonymous_api_admin

        puts _("Importing Errata")
        Katello::Erratum.import_all

        Host.find_each do |host|
          begin
            update_host_repositories(host)
          rescue => e
            error(e, host)
          end
        end

        if Host.any?
          puts _("Generating applicability for %s Content Hosts") % Host.count
          ForemanTasks.sync_task(::Actions::Katello::Host::GenerateApplicability,
                                 Host.all)
        end
      end
    end
  end
end
