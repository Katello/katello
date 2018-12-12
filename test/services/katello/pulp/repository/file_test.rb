require 'katello_test_helper'

module Katello
  module Service
    class Repository
      class FileBaseTest < ::ActiveSupport::TestCase
        include VCR::TestCase
        include RepositorySupport

        def setup
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy)
          @custom = katello_repositories(:generic_file)
        end
      end

      class FileTest < FileBaseTest
        def test_unit_keys
          upload = {'id' => '1', 'size' => '12333', 'checksum' => 'asf23421324', 'name' => 'test'}
          assert_equal [upload.except('id')], @custom.backend_service(@master).unit_keys([upload])
        end
      end
    end
  end
end
