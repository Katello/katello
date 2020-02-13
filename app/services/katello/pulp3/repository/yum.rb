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

        def import_distribution_data
          distribution = ::Katello::Pulp3::Distribution.fetch_content_list(repository_version: repo.version_href)
          if distribution.results.present?
            repo.update_attributes!(
              :distribution_version => distribution.results.first.release_version,
              :distribution_arch => distribution.results.first.arch,
              :distribution_family => distribution.results.first.release_name,
              :distribution_uuid => distribution.results.first.pulp_href,
              :distribution_bootable => self.class.distribution_bootable?(distribution)
            )
            unless distribution.results.first.variants.empty?
              unless distribution.results.first.variants.first.name.nil?
                repo.update_attributes!(:distribution_variant => distribution.results.first.variants.first.name)
              end
            end
          end
        end

        def self.distribution_bootable?(distribution)
          file_paths = distribution.results.first.images.map(&:path)
          file_paths.any? do |path|
            path.include?('vmlinuz') || path.include?('pxeboot') || path.include?('kernel.img') || path.include?('initrd.img') || path.include?('boot.iso')
          end
        end

        def partial_repo_path
          "/pulp/repos/#{repo.relative_path}/".sub('//', '/')
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
