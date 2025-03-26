class RemovePulp3MigratedHrefsFromContentTables < ActiveRecord::Migration[6.1]
  def change
    content_models = [Katello::Rpm, Katello::ModuleStream, Katello::Erratum, Katello::PackageGroup,
                      Katello::Srpm, Katello::FileUnit, Katello::DockerManifestList, Katello::DockerManifest, Katello::DockerTag]

    content_models.each do |model|
      remove_column model.table_name, :migrated_pulp3_href, :string
    end
  end
end
