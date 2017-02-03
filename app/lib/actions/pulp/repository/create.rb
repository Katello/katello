module Actions
  module Pulp
    module Repository
      class Create < Pulp::Abstract
        include Helpers::Presenter

        input_format do
          param :content_type
          param :pulp_id
          param :name
          param :feed
          param :ssl_ca_cert
          param :ssl_client_cert
          param :ssl_client_key
          param :unprotected
          param :checksum_type
          param :path
          param :with_importer
          param :docker_upstream_name
          param :download_policy
          param :capsule_id
          param :mirror_on_sync
          param :ssl_validation
          param :upstream_username
          param :upstream_password
        end

        def run
          output[:response] = pulp_extensions.repository.
              create_with_importer_and_distributors(input[:pulp_id],
                                                    importer,
                                                    distributors,
                                                    display_name: input[:name])
        end

        def importer
          case input[:content_type]
          when ::Katello::Repository::YUM_TYPE, ::Katello::Repository::FILE_TYPE
            yum_or_iso_importer
          when ::Katello::Repository::PUPPET_TYPE
            puppet_importer
          when ::Katello::Repository::DOCKER_TYPE
            docker_importer
          when ::Katello::Repository::OSTREE_TYPE
            ostree_importer
          else
            fail _("Unexpected repo type %s") % input[:content_type]
          end
        end

        def yum_or_iso_importer
          importer = case input[:content_type]
                     when ::Katello::Repository::YUM_TYPE
                       Runcible::Models::YumImporter.new
                     when ::Katello::Repository::FILE_TYPE
                       Runcible::Models::IsoImporter.new
                     end
          importer.feed            = input[:feed]
          importer.ssl_ca_cert     = input[:ssl_ca_cert]
          importer.ssl_client_cert = input[:ssl_client_cert]
          importer.ssl_client_key  = input[:ssl_client_key]
          importer.ssl_validation  = input[:ssl_validation]
          importer.download_policy = input[:download_policy] if input[:content_type] == ::Katello::Repository::YUM_TYPE
          importer.remove_missing  = input[:mirror_on_sync] if input[:content_type] == ::Katello::Repository::YUM_TYPE
          importer.basic_auth_username = input[:upstream_username] if input[:upstream_username].present?
          importer.basic_auth_password = input[:upstream_password] if input[:upstream_password].present?
          importer
        end

        def ostree_importer
          importer = Runcible::Models::OstreeImporter.new
          importer.feed            = input[:feed]
          importer.ssl_ca_cert     = input[:ssl_ca_cert]
          importer.ssl_client_cert = input[:ssl_client_cert]
          importer.ssl_client_key  = input[:ssl_client_key]
          importer.ssl_validation  = input[:ssl_validation]
          importer.basic_auth_username = input[:upstream_username] if input[:upstream_username].present?
          importer.basic_auth_password = input[:upstream_password] if input[:upstream_password].present?
          importer
        end

        def puppet_importer
          importer = Runcible::Models::PuppetImporter.new
          importer.feed            = input[:feed]
          importer.ssl_ca_cert     = input[:ssl_ca_cert]
          importer.ssl_client_cert = input[:ssl_client_cert]
          importer.ssl_client_key  = input[:ssl_client_key]
          importer.ssl_validation  = input[:ssl_validation]
          importer.basic_auth_username = input[:upstream_username] if input[:upstream_username].present?
          importer.basic_auth_password = input[:upstream_password] if input[:upstream_password].present?
          importer
        end

        def docker_importer
          importer = Runcible::Models::DockerImporter.new
          importer.upstream_name   = input[:docker_upstream_name] if input[:docker_upstream_name]
          importer.feed            = input[:feed]
          importer.enable_v1       = false
          importer.ssl_validation  = input[:ssl_validation]
          importer.basic_auth_username = input[:upstream_username] if input[:upstream_username].present?
          importer.basic_auth_password = input[:upstream_password] if input[:upstream_password].present?
          importer
        end

        def distributors
          case input[:content_type]
          when ::Katello::Repository::YUM_TYPE
            distributors = [yum_distributor, export_distributor]
            distributors << yum_clone_distributor unless input[:capsule_id]
          when ::Katello::Repository::FILE_TYPE
            distributors = [iso_distributor]
          when ::Katello::Repository::PUPPET_TYPE
            distributors = input[:path].blank? ? [] : [puppet_install_distributor]
            distributors << puppet_distributor
          when ::Katello::Repository::DOCKER_TYPE
            distributors = [docker_distributor]
          when ::Katello::Repository::OSTREE_TYPE
            distributors = [ostree_distributor]
          else
            fail _("Unexpected repo type %s") % input[:content_type]
          end

          distributors
        end

        def yum_distributor
          yum_dist_options = { protected: true,
                               id: input[:pulp_id],
                               auto_publish: true }
          yum_dist_options[:checksum_type] = input[:checksum_type] if input[:checksum_type]
          Runcible::Models::YumDistributor.new(input[:path],
                                               input[:unprotected] || false,
                                               true,
                                               yum_dist_options)
        end

        def yum_clone_distributor
          Runcible::Models::YumCloneDistributor.new(id: "#{input[:pulp_id]}_clone",
                                                    destination_distributor_id: input[:pulp_id])
        end

        def iso_distributor
          Runcible::Models::IsoDistributor.new(true, true).tap do |dist|
            dist.auto_publish = true
          end
        end

        def puppet_distributor
          options = { id: "#{input[:pulp_id]}_puppet", auto_publish: true }
          Runcible::Models::PuppetDistributor.new(nil,
                                                  input[:unprotected] || false,
                                                  true,
                                                  options)
        end

        def puppet_install_distributor
          Runcible::Models::PuppetInstallDistributor.new(input[:path],
                                                         id: input[:pulp_id],
                                                         auto_publish: true)
        end

        def docker_distributor
          options = { protected: !input[:unprotected] || false,
                      id: input[:pulp_id],
                      auto_publish: true,
                      repo_registry_id: input[:repo_registry_id]}
          Runcible::Models::DockerDistributor.new(options)
        end

        def export_distributor
          # "false, false" means "no http export, no https export". We only
          # export to a directory.
          Runcible::Models::ExportDistributor.new(false, false, input[:path])
        end

        def ostree_distributor
          options = { id: input[:pulp_id],
                      relative_path: input[:path],
                      auto_publish: true }
          Runcible::Models::OstreeDistributor.new(options)
        end
      end
    end
  end
end
