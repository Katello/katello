module Katello
  module Pulp3
    class AnsibleCollection < PulpContentUnit
      include LazyAccessor
      PULPCORE_CONTENT_TYPE = "ansible.collection_version".freeze

      def self.content_api
        PulpAnsibleClient::ContentCollectionVersionsApi.new(Katello::Pulp3::Api::AnsibleCollection.new(SmartProxy.pulp_primary!).api_client)
      end

      def self.ids_for_repository(repo_id)
        repo = Katello::Pulp3::Repository::AnsibleCollection.new(Katello::Repository.find(repo_id), SmartProxy.pulp_primary)
        repo_content_list = repo.content_list
        repo_content_list.map { |content| content.try(:pulp_href) }
      end

      def self.pulp_data(_pulp_href)
        #No content read method
        fail NotImplementedError
      end

      def self.generate_model_row(unit)
        {
          pulp_id: unit['pulp_href'],
          checksum: unit['sha256'],
          namespace: unit['namespace'],
          version: unit['version'],
          name: unit['name'],
          description: unit['description']
        }
      end

      def self.insert_child_associations(units, pulp_id_to_id)
        insert_tags units
        collection_tag_rows = []
        units.each do |unit|
          katello_id = pulp_id_to_id[unit['pulp_href']]
          #delete old tags
          unit_tags = unit['tags']&.map { |tag| tag[:name] }
          Katello::AnsibleCollectionTag.where(:ansible_collection_id => katello_id).where.not(:ansible_tag_id => Katello::AnsibleTag.where(:name => unit_tags)).delete_all
          collection_tag_rows += Katello::AnsibleTag.where(:name => unit_tags)&.pluck(:id)&.map { |tag_id| {ansible_collection_id: katello_id, ansible_tag_id: tag_id} }
        end

        collection_tag_rows.flatten!
        Katello::AnsibleCollectionTag.insert_all(collection_tag_rows, unique_by: [:ansible_collection_id, :ansible_tag_id]) unless collection_tag_rows.empty?
      end

      def self.insert_tags(units)
        tag_names = units.map { |unit| unit['tags']&.map { |tag| tag[:name] } }&.flatten
        tag_rows = tag_names&.compact&.map { |name| {name: name } }
        Katello::AnsibleTag.insert_all(tag_rows, unique_by: [:name]) if tag_rows.any?
      end
    end
  end
end
