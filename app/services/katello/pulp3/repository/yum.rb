require 'pulp_rpm_client'

module Katello
  module Pulp3
    class Repository
      class Yum < ::Katello::Pulp3::Repository
        def remote_options
          if root.url.blank?
            common_remote_options.merge(url: nil, policy: root.download_policy)
          else
            common_remote_options.merge(policy: root.download_policy)
          end
        end

        def distribution_options(path)
          {
            base_path: path,
            publication: repo.publication_href,
            name: "#{generate_backend_object_name}"
          }
        end
      end
    end
  end
end
