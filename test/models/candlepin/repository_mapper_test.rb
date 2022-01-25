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
      assert_includes mapper.path, subs[:basearch]
      assert_includes mapper.path, subs[:releasever]
    end

    def test_unused_substitutions_bad
      subs = {:basearch => 'x86_64', :releasever => "greatest8", :wild_card => "ddd"}.with_indifferent_access
      mapper = Candlepin::RepositoryMapper.new(@product_content.product, @product_content.content, subs)
      refute_equal subs, mapper.substitutions
      assert_equal subs.slice(:basearch, :releasever), mapper.substitutions
      assert_includes mapper.path, subs[:basearch]
      assert_includes mapper.path, subs[:releasever]
      refute_includes mapper.path, subs[:wild_card]
    end

    def test_unprotected_suse
      mapper = Candlepin::RepositoryMapper.new(@product_content.product, @product_content.content, {})
      mapper.expects(:path).returns("/special/suse")
      assert mapper.unprotected?

      mapper.expects(:path).returns("/special/redhat")
      assert_equal mapper.unprotected?, false
    end

    def test_airgapped_no_http
      @product_content.product.organization.cdn_configuration.update!(type: ::Katello::CdnConfiguration::AIRGAPPED_TYPE)
      mapper = Candlepin::RepositoryMapper.new(@product_content.product, @product_content.content, {})
      mapper.expects(:substitutor).never
      mapper.validate!
    end

    def test_download_policy
      mapper = Candlepin::RepositoryMapper.new(@product_content.product, @product_content.content, {})

      Setting[:default_download_policy] = 'on_demand'
      Setting[:default_redhat_download_policy] = 'immediate'

      assert_equal 'immediate', mapper.download_policy
    end
  end
end
