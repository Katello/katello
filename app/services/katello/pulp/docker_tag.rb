module Katello
  module Pulp
    class DockerTag < PulpContentUnit
      CONTENT_TYPE = "docker_tag".freeze

      def update_model(model)
        taggable_class = backend_data['manifest_type'] == "list" ? ::Katello::DockerManifestList : ::Katello::DockerManifest
        model.docker_taggable = taggable_class.find_by(:digest => backend_data['manifest_digest'])
        model.repository_id = ::Katello::Repository.find_by(:pulp_id => backend_data['repo_id']).try(:id)
        model.name = backend_data['name']
        model.save!
      end
    end
  end
end
