module Katello
  module Pulp
    class Repository
      class Yum < ::Katello::Pulp::Repository
        def generate_master_importer
          config = {
            download_policy: root.download_policy,
            remove_missing: root.mirror_on_sync?,
            feed: root.url,
            type_skip_list: root.ignorable_content
          }
          importer_class.new(config.merge(master_importer_connection_options))
        end

        def generate_mirror_importer
          config = {
            download_policy: smart_proxy_download_policy,
            remove_missing: true,
            feed: external_url(true)
          }
          importer_class.new(config.merge(mirror_importer_connection_options))
        end

        def partial_repo_path
          "/pulp/repos/#{repo.relative_path}/".sub('//', '/')
        end

        def importer_class
          Runcible::Models::YumImporter
        end

        def generate_distributors
          yum_dist_id = repo.pulp_id
          options = {
            protected: true,
            id: yum_dist_id,
            auto_publish: true,
            checksum_type: repo.saved_checksum_type || root.checksum_type
          }
          distributors = [Runcible::Models::YumDistributor.new(repo.relative_path, root.unprotected, true, options)]

          if smart_proxy.pulp_master?
            distributors << Runcible::Models::YumCloneDistributor.new(:id => "#{repo.pulp_id}_clone",
                                                                   :destination_distributor_id => yum_dist_id)
            distributors << Runcible::Models::ExportDistributor.new(false, false, repo.relative_path)
          end
          distributors
        end

        def smart_proxy_download_policy
          policy = smart_proxy.download_policy || Setting[:default_proxy_download_policy]
          if policy == ::SmartProxy::DOWNLOAD_INHERIT
            self.root.download_policy
          else
            policy
          end
        end
      end
    end
  end
end
