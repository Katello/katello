require 'katello_test_helper'

module Katello
  class RepositoryMapperTest < ActiveSupport::TestCase
    def setup
      @repo1 = katello_repositories(:fedora_17_x86_64)
      @product1 = @repo1.product
    end

    def test_unprotected_suse
      mapper = Candlepin::RepositoryMapper.new(@product1, @repo1, {})
      mapper.expects(:path).returns("/special/suse")
      assert mapper.unprotected?

      mapper.expects(:path).returns("/special/redhat")
      assert_equal mapper.unprotected?, false
    end

    def test_download_policy
      mapper = Candlepin::RepositoryMapper.new(@product1, @repo1, {})

      Setting[:default_download_policy] = 'on_demand'
      Setting[:default_redhat_download_policy] = 'immediate'

      assert_equal 'immediate', mapper.download_policy
    end
  end
end
