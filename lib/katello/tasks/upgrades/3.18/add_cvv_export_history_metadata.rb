namespace :katello do
  namespace :upgrades do
    namespace '3.18' do
      task :add_cvv_export_history_metadata => ['environment', 'check_ping'] do
        smart_proxy = SmartProxy.pulp_primary!

        Katello::ContentViewVersionExportHistory.includes(:content_view_version).where(metadata: nil).find_each do |export_history|
          export = ::Katello::Pulp3::ContentViewVersion::Export.new(
            content_view_version: export_history.content_view_version,
            smart_proxy: smart_proxy
          )

          export_history.update(metadata: export.generate_metadata)
        end
      end
    end
  end
end
