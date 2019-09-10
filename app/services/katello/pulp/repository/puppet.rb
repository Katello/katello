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

        def auto_publish?
          (smart_proxy.try(:pulp_mirror?) && !@repo.library_instance?) || false
        end

        def generate_distributors
          puppet_install_dist = Runcible::Models::PuppetInstallDistributor.new(puppet_install_distributor_path,
                                                                               :subdir => 'modules',
                                                                               :id => repo.pulp_id,
                                                                               :auto_publish => auto_publish?)
          puppet_dist = Runcible::Models::PuppetDistributor.new(nil, (root.unprotected || false), true,
                                                                :id => "#{repo.pulp_id}_puppet", :auto_publish => true)
          [puppet_dist, puppet_install_dist]
        end

        def puppet_install_distributor_path
          puppet_env = ::Environment.construct_name(repo.organization, repo.environment, repo.content_view)
          ::File.join(smart_proxy.puppet_path, puppet_env)
        end

        def distributors_to_publish(_options)
          if !repo.content_view.default? && !repo.archive?
            {Runcible::Models::PuppetDistributor => {}, Runcible::Models::PuppetInstallDistributor => {}}
          else
            {Runcible::Models::PuppetDistributor => {}}
          end
        end

        def partial_repo_path
          "/pulp/puppet/#{repo.pulp_id}/"
        end

        def importer_class
          Runcible::Models::PuppetImporter
        end

        def copy_contents(destination_repo, options = {})
          if options[:puppet_modules]
            module_uuids = options[:puppet_modules].pluck(:pulp_id)
            clauses = {'filters': { 'association': { 'unit_id' => { "$in" => module_uuids } } } }
          else
            clauses = {}
          end
          @smart_proxy.pulp_api.extensions.puppet_module.copy(@repo.pulp_id, destination_repo.pulp_id, clauses)
        end
      end
    end
  end
end
