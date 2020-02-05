require 'katello_test_helper'

module Katello
  class RepositoryMapperTest < ActiveSupport::TestCase
    def setup
      @product_content = katello_product_contents(:rhel_content)
    end

    def test_unused_substitutions_good
      subs = {:basearch => 'x86_64', :releasever => "greatest8"}.with_indifferent_access
      mapper = Candlepin::RepositoryMapper.new(@product_content.product, @product_content.content, subs)
      assert_equal subs, mapper.substitutions
      assert mapper.path.include?(subs[:basearch])
      assert mapper.path.include?(subs[:releasever])
    end

    def test_unused_substitutions_bad
      subs = {:basearch => 'x86_64', :releasever => "greatest8", :wild_card => "ddd"}.with_indifferent_access
      mapper = Candlepin::RepositoryMapper.new(@product_content.product, @product_content.content, subs)
      refute_equal subs, mapper.substitutions
      assert_equal subs.slice(:basearch, :releasever), mapper.substitutions
      assert mapper.path.include?(subs[:basearch])
      assert mapper.path.include?(subs[:releasever])
      refute mapper.path.include?(subs[:wild_card])
    end

    def test_unprotected_suse
      mapper = Candlepin::RepositoryMapper.new(@product_content.product, @product_content.content, {})
      mapper.expects(:path).returns("/special/suse")
      assert mapper.unprotected?

      mapper.expects(:path).returns("/special/redhat")
      assert_equal mapper.unprotected?, false
    end

    def test_download_policy
      mapper = Candlepin::RepositoryMapper.new(@product_content.product, @product_content.content, {})

      Setting[:default_download_policy] = 'on_demand'
      Setting[:default_redhat_download_policy] = 'immediate'

      assert_equal 'immediate', mapper.download_policy
    end
  end
end
