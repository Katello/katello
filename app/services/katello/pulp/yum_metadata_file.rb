module Katello
  module Pulp
    class YumMetadataFile < PulpContentUnit
      CONTENT_TYPE = "yum_repo_metadata_file".freeze

      def update_model(model)
        shared_attributes = backend_data.keys & model.class.column_names
        shared_json = backend_data.select { |key, _v| shared_attributes.include?(key) }
        repo = ::Katello::Repository.find_by(:pulp_id => backend_data['repo_id']).try(:id)
        filename = find_name_from_json(backend_data)
        model.update!(shared_json.merge(repository_id: repo, name: filename))
        if repo
          Katello::YumMetadataFile.where("id != ? AND repository_id = ? AND name = ? AND checksum = ?",
                                         model.id, repo, filename, model.checksum).delete_all
        end
      end

      def find_name_from_json(json)
        # get the name of the metadata file.
        # Notice that pulp does not have a way to get name of the metadata file
        # so we infer it from the _storage_path
        # for example from the following storage path
        #  "/var/lib/pulp/content/units/yum_repo_metadata_file/..../050-productid.gz"
        # we find the right most '/' and return everything after that
        # i.e ->  "050-productid.gz"
        File.basename(json["_storage_path"])
      end
    end
  end
end
