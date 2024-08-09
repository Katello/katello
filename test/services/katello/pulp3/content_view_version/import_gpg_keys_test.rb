require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportGpgKeysTest < ActiveSupport::TestCase
          include Support::Actions::Fixtures

          def test_import
            org = get_organization
            gpg_key = "MyCoolKey10000"
            existing_gpgkey = katello_gpg_keys(:fedora_gpg_key)
            updated_content = "#{existing_gpgkey.content} additional content!"

            metadata_gpg_keys = [
              stub('existing gpg', name: existing_gpgkey.name, content: updated_content),
              stub('new gpg', name: gpg_key, content: 'new content'),
            ]

            importer = Katello::Pulp3::ContentViewVersion::ImportGpgKeys.new(
                organization: org,
                metadata_gpg_keys: metadata_gpg_keys
            )

            importer.import!

            assert_equal updated_content, org.gpg_keys.find_by(name: existing_gpgkey.name).content
            refute_nil org.gpg_keys.find_by(name: gpg_key)
          end
        end
      end
    end
  end
end
