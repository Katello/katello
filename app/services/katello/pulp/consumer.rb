module Katello
  module Pulp
    class Consumer
      include LazyAccessor

      attr_accessor :uuid

      lazy_accessor :pulp_facts, :initializer => lambda { |_s| Katello.pulp_server.extensions.consumer.retrieve(uuid) }
      lazy_accessor :package_profile, :initializer => lambda { |_s| fetch_package_profile }
      lazy_accessor :simple_packages, :initializer => (lambda do |_s|
                                                         fetch_package_profile["profile"].
                                                           collect { |package| Katello::Pulp::SimplePackage.new(package) }
                                                       end)

      def initialize(uuid)
        self.uuid = uuid
      end

      def upload_package_profile(profile)
        Katello.pulp_server.extensions.consumer.upload_profile(self.uuid, 'rpm', profile)
      end

      def upload_module_stream_profile(profile)
        Katello.pulp_server.extensions.consumer.upload_profile(self.uuid, 'modulemd', profile)
      end

      def applicable_ids(content_unit_type)
        consumer_method = case content_unit_type
                          when ::Katello::Erratum::CONTENT_TYPE
                            :applicable_errata
                          when ::Katello::ModuleStream::CONTENT_TYPE
                            :applicable_module_streams
                          else
                            :applicable_rpms
                          end
        response = Katello.pulp_server.extensions.consumer.send(consumer_method, [self.uuid])
        return [] if response.empty?
        response[0]['applicability'][content_unit_type] || []
      end

      def bind_yum_repositories(ids)
        bind_repos(Runcible::Models::YumDistributor.type_id, bound_yum_repositories, ids, :notify_agent => false)
      end

      def bound_yum_repositories
        bindings(Runcible::Models::YumDistributor.type_id)
      end

      private

      def bindings(type_id)
        bindings = Katello.pulp_server.extensions.consumer.retrieve_bindings(uuid)
        bindings.select { |b| b['type_id'] == type_id }.collect { |repo| repo["repo_id"] }
      end

      def bind_repos(distributor_type, existing_ids, update_ids, bind_options = {})
        bound_ids     = existing_ids
        intersection  = update_ids & bound_ids
        bind_ids      = update_ids - intersection
        unbind_ids    = bound_ids - intersection

        unbind_repo_ids(unbind_ids, distributor_type)
        bind_repo_ids(bind_ids, distributor_type, bind_options)
      end

      def unbind_repo_ids(repo_ids, distributor_type)
        repo_ids.each do |repo_id|
          Katello.pulp_server.extensions.consumer.unbind_all(uuid, repo_id, distributor_type)
        rescue => e
          Rails.logger.error "Failed to unbind repo #{repo_id}: #{e}, #{e.backtrace.join("\n")}"
        end
      end

      def bind_repo_ids(repo_ids, distributor_type, bind_options)
        repo_ids.each do |repo_id|
          Katello.pulp_server.extensions.consumer.bind_all(uuid, repo_id, distributor_type, bind_options)
        rescue => e
          Rails.logger.error "Failed to bind repo #{repo_id}: #{e}, #{e.backtrace.join("\n")}"
        end
      end
    end
  end
end
