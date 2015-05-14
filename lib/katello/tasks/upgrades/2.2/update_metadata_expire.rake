namespace :katello do
  namespace :upgrades do
    namespace '2.2' do
      task :update_metadata_expire => ["environment"]  do
        User.current = User.anonymous_api_admin
        puts _("Updating Expire Metadata for Custom Content")

        Katello::Product.find_each do |product|
          unless product.redhat?
            product.repositories.each do |repo|
              ForemanTasks.sync_task(::Actions::Katello::Repository::Update, repo, {})
            end
          end
        end
      end
    end
  end
end
