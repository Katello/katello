require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      class Repository
        class GenericTest < ::ActiveSupport::TestCase
          include Katello::Pulp3Support

          def setup
            @repo = katello_repositories(:fedora_17_x86_64)
            @proxy = SmartProxy.pulp_primary
            @service = Katello::Pulp3::Repository::Generic.new(@repo, @proxy)
          end

          def test_distribution_options_includes_publication_attribute_if_content_type_publishes
            @repo.publication_href = 'a_version_href'
            @repo.root.checksum_type = 'sha512'

            publication_options = @service.distribution_options('/')

            assert_includes publication_options.keys, :publication
          end

          def test_distribution_options_excludes_publication_attribute_if_content_type_skips_publish
            Katello::RepositoryTypeManager.find("yum").stubs(:pulp3_skip_publication).returns(true)
            @repo.publication_href = 'a_version_href'
            @repo.root.checksum_type = '512'

            publication_options = @service.distribution_options('/')

            refute_includes publication_options.keys, :publication
          end

          def test_remote_options_includes_download_policy_for_python
            python_repo = katello_repositories(:pulp3_python_1)
            python_repo.root.update(download_policy: 'on_demand')
            service = Katello::Pulp3::Repository::Generic.new(python_repo, @proxy)

            options = service.remote_options
            assert_includes options.keys, :policy
            assert_equal 'on_demand', options[:policy]
          end

          def test_remote_options_filters_empty_string_values
            python_repo = katello_repositories(:pulp3_python_1)
            python_repo.root.update(
              generic_remote_options: '{"keep_latest_packages":"","includes":["pip"]}'
            )
            service = Katello::Pulp3::Repository::Generic.new(python_repo, @proxy)

            options = service.remote_options
            refute_includes options.keys, :keep_latest_packages
            assert_equal ['pip'], options[:includes]
          end
        end
      end
    end
  end
end
