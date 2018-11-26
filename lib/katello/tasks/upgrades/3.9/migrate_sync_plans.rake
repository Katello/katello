namespace :katello do
  namespace :upgrades do
    namespace '3.9' do
      desc "Migrate Pulp Sync Plans to new recurring logics"
      task :migrate_sync_plans => ["environment"] do
        User.current = User.anonymous_admin
        puts "Starting recurring logic for migrated sync plans and deleting Pulp schedules"

        Katello::SyncPlan.find_each do |sync_plan|
          sync_plan.associate_recurring_logic
          sync_plan.save!
          if sync_plan.foreman_tasks_recurring_logic.state.nil?
            sync_plan.start_recurring_logic
            sync_plan.foreman_tasks_recurring_logic.enabled = false unless sync_plan.enabled
          end

          sync_plan.products.each do |product|
            product.repos(product.library).each do |repo_k|
              repo = ::Katello::Repository.find(repo_k.id)
              begin
                Katello.pulp_server.extensions.repository.remove_schedules(repo.pulp_id, repo.importer_type)
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
