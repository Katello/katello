namespace :katello do
  namespace :upgrades do
    namespace '4.9' do
      desc "Update custom products enablement"
      task :update_custom_products_enablement => ['environment'] do
        if ::Katello::ProductContent.custom.where(enabled: true).exists?
          migrator = Katello::Util::DefaultEnablementMigrator.new
          migrator.execute!
        end
      end
    end
  end
end
