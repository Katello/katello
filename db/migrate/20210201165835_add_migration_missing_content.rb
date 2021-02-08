class AddMigrationMissingContent < ActiveRecord::Migration[6.0]
  def change
    content_models = [Katello::Rpm, Katello::ModuleStream, Katello::Erratum, Katello::PackageGroup, Katello::YumMetadataFile,
                      Katello::Srpm, Katello::FileUnit, Katello::DockerManifestList, Katello::DockerManifest, Katello::DockerTag,
                      Katello::Deb]

    content_models.each do |model|
      add_column model.table_name, :missing_from_migration, :bool, :default => false, :null => false
      add_column model.table_name, :ignore_missing_from_migration, :bool, :default => false, :null => false
    end
  end
end
