module Katello
  module Pulp3
    class AnsibleCollection < PulpContentUnit
      include LazyAccessor
      CONTENT_TYPE = "ansible collection".freeze

      lazy_accessor :pulp_facts, :initializer => :backend_data

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::AnsibleCollection.new(Katello::Repository.find(repo_id), SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:_href) }
      end

      def self.pulp_data(_href)
        #No content read method
        fail NotImplementedError
      end

      def update_model(model)
        custom_json = {}
        custom_json['checksum'] = backend_data['sha256']
        custom_json['namespace'] = backend_data['namespace']
        custom_json['version'] = backend_data['version']
        custom_json['name'] = backend_data['name']
        model.update_attributes!(custom_json)
      end

      def self.content_unit_list(page_opts)
        SmartProxy.pulp_master!.pulp3_api.content_ansible_collections_list page_opts
      end
    end
  end
end
