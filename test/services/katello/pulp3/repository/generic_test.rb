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
            @repo.root.checksum_type = 'sha1'

            publication_options = @service.distribution_options('/')

            assert_includes publication_options.keys, :publication
          end

          def test_distribution_options_excludes_publication_attribute_if_content_type_skips_publish
            Katello::RepositoryTypeManager.find("yum").stubs(:pulp3_skip_publication).returns(true)
            @repo.publication_href = 'a_version_href'
            @repo.root.checksum_type = 'sha1'

            publication_options = @service.distribution_options('/')

            refute_includes publication_options.keys, :publication
          end
        end
      end
    end
  end
end
