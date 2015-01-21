namespace :katello do
  namespace :upgrades do
    namespace '2.2' do
      task :update_gpg_key_urls => ["environment"]  do
        User.current = User.anonymous_api_admin
        puts _("Importing GPG Key Urls to support Capsule Communication")

        Katello::Product.find_each do |product|
          unless product.redhat?
            product.repositories.each do |repo|
              if repo.yum_gpg_key_url && repo.yum_gpg_key_url != repo.content.gpgUrl
                ForemanTasks.sync_task(::Actions::Katello::Repository::Update, repo, {})
              end
            end
          end
        end
      end
    end
  end
end
