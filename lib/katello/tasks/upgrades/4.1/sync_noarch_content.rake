namespace :katello do
  namespace :upgrades do
    namespace '4.1' do
      desc "Synchronize arches field of content in candlepin which should be unset."
      task :sync_noarch_content => ['environment'] do
        roots = Katello::RootRepository.joins(:product).merge(Katello::Product.custom).where(arch: 'noarch')
        roots.each do |root|
          Katello::Resources::Candlepin::Content.update(root.library_instance.organization.label, id: root.content_id, arches: '')
        rescue RestClient::NotFound
          #skip content not found
        end
      end
    end
  end
end
