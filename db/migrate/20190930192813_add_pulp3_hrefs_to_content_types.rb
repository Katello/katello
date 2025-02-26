class AddPulp3HrefsToContentTypes < ActiveRecord::Migration[5.2]
  def change
    content_models = [Katello::Rpm, Katello::ModuleStream, Katello::Erratum, Katello::PackageGroup,
                      Katello::Srpm, Katello::FileUnit, Katello::DockerManifestList, Katello::DockerManifest, Katello::DockerTag]

    content_models.each do |model|
      add_column model.table_name, :migrated_pulp3_href, :string, :default => nil, :null => true
    end
  end
end
