require 'pulp_deb_client'

module Katello
  module Pulp3
    class Repository
      class Apt < ::Katello::Pulp3::Repository
        SIGNING_SERVICE_NAME = 'katello_deb_sign'.freeze

        def remote_options
          deb_remote_options = {
            policy: root.download_policy,
            distributions: root.deb_releases
          }
          deb_remote_options[:components] = root.deb_components.present? ? root.deb_components : nil
          deb_remote_options[:architectures] = root.deb_architectures.present? ? root.deb_architectures : nil

          if root.url.blank?
            deb_remote_options[:url] = nil
          end

          deb_remote_options[:gpgkey] = root.gpg_key.present? ? root.gpg_key.content : nil

          common_remote_options.merge(deb_remote_options)
        end

        def mirror_remote_options
          {
            distributions: repo.deb_releases + "#{' default' unless repo.deb_releases.include? 'default'}"
          }
        end

        def publication_options(repository_version)
          ss = api.signing_services_api.list(name: SIGNING_SERVICE_NAME).results
          popts = super(repository_version)
          popts.merge!(
            {
              structured: true, # publish real suites (e.g. 'stable')
              simple: true # publish all into 'default'-suite
            }
          )
          popts[:signing_service] = ss[0].pulp_href if ss && ss.length == 1
          popts
        end

        def mirror_publication_options
          {
            # Since we are synchronizing the "default" distribution from the simple publisher on the server,
            # it will be included in the structured publish. Therefore, we MUST NOT use the simple publisher
            # on the proxy, since this would collide!
            #simple: true,
            structured: true # publish real suites (e.g. 'stable')
          }
        end

        def distribution_options(path)
          {
            base_path: path,
            publication: repo.publication_href,
            name: "#{generate_backend_object_name}"
          }
        end

        def partial_repo_path
          "/pulp/deb/#{repo.relative_path}/".sub('//', '/')
        end

        def copy_content_for_source
          # TODO
          fail NotImplementedError
        end

        def regenerate_applicability
          # TODO
          fail NotImplementedError
        end
      end
    end
  end
end
