namespace :katello do
  namespace :upgrades do
    namespace '3.9' do
      def importer_type(repo)
        case repo.content_type
        when Katello::Repository::YUM_TYPE
          Runcible::Models::YumImporter::ID
        when Katello::Repository::FILE_TYPE
          Runcible::Models::IsoImporter::ID
        when Katello::Repository::PUPPET_TYPE
          Runcible::Models::PuppetImporter::ID
        when Katello::Repository::DOCKER_TYPE
          Runcible::Models::DockerImporter::ID
        when Katello::Repository::OSTREE_TYPE
          Runcible::Models::OstreeImporter::ID
        when Katello::Repository::DEB_TYPE
          Runcible::Models::DebImporter::ID
        else
          fail _("Unexpected repo type %s") % repo.content_type
        end
      end

      desc "Migrate Pulp Sync Plans to new recurring logics"
      task :migrate_sync_plans => ["environment"] do
        User.current = User.anonymous_admin
        puts "Starting recurring logic for migrated sync plans and deleting Pulp schedules"

        Katello::SyncPlan.find_each do |sync_plan|
          if sync_plan.foreman_tasks_recurring_logic.nil?
            sync_plan.associate_recurring_logic
            sync_plan.save!
            if sync_plan.foreman_tasks_recurring_logic.state.nil?
              sync_plan.start_recurring_logic
              sync_plan.foreman_tasks_recurring_logic.enabled = false unless sync_plan[:enabled]
            end
          end
          sync_plan.products.each do |product|
            product.repos(product.library).each do |repo_k|
              repo = ::Katello::Repository.find(repo_k.id)
              begin
                Katello.pulp_server.extensions.repository.remove_schedules(repo.pulp_id, importer_type(repo))
              rescue RestClient::ResourceNotFound
                puts "Could not update repository #{repo.id}, missing in pulp."
              end
            end
          end
        end
      end
    end
  end
end
