require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class FileBaseTest < ::ActiveSupport::TestCase
        include VCR::TestCase
        include RepositorySupport

        def setup
          @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy)
          @custom = katello_repositories(:generic_file)
          @repo = katello_repositories(:pulp3_file_1)
          RepositorySupport.create_and_sync_repo(@repo)
        end

        def teardown
          RepositorySupport.destroy_repo(@repo)
        end
      end

      class FileVCRTest < FileBaseTest
        def test_sync_index_content
          @repo.index_content
          assert_equal @repo.files.count, 3
        ensure
          teardown
        end
      end

      class FileNonVCRTest < ::ActiveSupport::TestCase
        def setup
          @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy)
          @custom = katello_repositories(:generic_file)
        end

        def test_unit_keys
          upload = {'id' => '1', 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test'}
          assert_equal [upload.except('id')], @custom.backend_service(@primary).unit_keys([upload])
        end
      end
    end
  end
end
