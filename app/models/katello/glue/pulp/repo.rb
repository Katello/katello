module Katello
  module Glue::Pulp::Repo
    # TODO: move into submodules
    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods
    end

    module InstanceMethods
      def last_sync
        last = self.latest_dynflow_sync
        last.nil? ? nil : last.to_s
      end

      def initialize(attrs = nil)
        if attrs.nil?
          super
        else
          #rename "type" to "cp_type" (activerecord and candlepin variable name conflict)
          #if attrs.has_key?(type_key) && !(attrs.has_key?(:cp_type) || attrs.has_key?('cp_type'))
          #  attrs[:cp_type] = attrs[type_key]
          #end

          attrs_used_by_model = attrs.reject do |k, _v|
            !self.class.column_defaults.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
          end
          super(attrs_used_by_model)
        end
      end

      def srpm_count
        # TODO: Pulp 3 replacement?
        0
      end

      def to_hash
        as_json.merge(:sync_state => sync_state)
      end

      def package_group_count
        # TODO: Pulp 3 replacement?
        0
      end

      def sync_status
        # TODO: Pulp 3 replacement?
        PulpSyncStatus.new(:state => PulpSyncStatus::Status::NOT_SYNCED)
      end

      def sync_state
        # TODO: Pulp 3 replacement?
        PulpSyncStatus::Status::NOT_SYNCED
      end

      def synced?
        # TODO: Pulp 3 replacement?
        false
      end

      def docker?
        self.content_type == Repository::DOCKER_TYPE
      end

      def file?
        self.content_type == Repository::FILE_TYPE
      end

      def yum?
        self.content_type == Repository::YUM_TYPE
      end

      def ostree?
        self.content_type == Repository::OSTREE_TYPE
      end

      def deb?
        self.content_type == Repository::DEB_TYPE
      end

      def ansible_collection?
        self.content_type == Repository::ANSIBLE_COLLECTION_TYPE
      end
    end
  end
end
