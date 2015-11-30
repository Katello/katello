namespace :katello do
  namespace :upgrades do
    namespace '2.5' do
      task :add_export_distributor => ["environment"]  do
        User.current = User.anonymous_api_admin
        puts _("Refreshing existing repositories to add export distributor")

        Katello::Product.find_each do |product|
          product.repositories.each do |repo|
            ForemanTasks.sync_task(::Actions::Katello::Repository::RefreshRepository, repo)
          end
        end
      end
    end
  end
end
