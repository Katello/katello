module Katello
  module Pulp
    class Repository
      class Puppet < ::Katello::Pulp::Repository
        def generate_master_importer
          config = {
            feed: root.url,
            remove_missing: root.mirror_on_sync?
          }
          importer_class.new(config.merge(master_importer_connection_options))
        end

        def generate_mirror_importer
          config = {
            :feed => self.external_url,
            :remove_missing => true
          }
          importer_class.new(config.merge(mirror_importer_connection_options))
        end

        def generate_distributors
          puppet_install_dist = Runcible::Models::PuppetInstallDistributor.new(puppet_install_distributor_path, :id => repo.pulp_id, :auto_publish => true)
          puppet_dist = Runcible::Models::PuppetDistributor.new(nil, (root.unprotected || false), true,
                                                                :id => "#{repo.pulp_id}_puppet", :auto_publish => true)
          [puppet_dist, puppet_install_dist]
        end

        def puppet_install_distributor_path
          puppet_env = ::Environment.construct_name(repo.organization, repo.environment, repo.content_view)
          ::File.join(smart_proxy.puppet_path, puppet_env, 'modules')
        end

        def partial_repo_path
          "/pulp/puppet/#{repo.pulp_id}/"
        end

        def importer_class
          Runcible::Models::PuppetImporter
        end
      end
    end
  end
end
