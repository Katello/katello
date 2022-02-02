namespace :katello do
  namespace :upgrades do
    namespace '4.4' do
      desc "Republish imported CVs that aren't published"
      task :publish_import_cvvs => ["environment"] do
        ::ForemanTasks.dynflow.config.remote = true
        ::ForemanTasks.dynflow.initialize!

        User.current = User.anonymous_admin

        Katello::Repository.in_content_views(Katello::ContentView.where(:import_only => true)).where(:publication_href => nil).pluck(:content_view_version_id).uniq.each do |cvv_id|
          ForemanTasks.async_task(Actions::Katello::ContentViewVersion::RepublishRepositories, ::Katello::ContentViewVersion.find(cvv_id))
        end
      end
    end
  end
end
