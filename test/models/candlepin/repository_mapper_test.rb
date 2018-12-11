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
      refute mapper.unprotected?
    end
  end
end
