require 'katello_test_helper'

module Katello
  class ProductContentFinderTestBase < ActiveSupport::TestCase
    def product_hash(product, repo, name)
      {
        :id => product.cp_id,
        :productContent => [
          {
            :content => {
              :name => name,
              :label => name,
              :id => repo.content_id
            }
          }
        ]
      }.with_indifferent_access
    end

    def setup
      @product1 = katello_products(:fedora)
      @product2 = katello_products(:redhat)
      @repo1 = katello_repositories(:fedora_17_x86_64)
      @repo2 = katello_repositories(:rhel_7_x86_64)
      @repo2_cv = katello_repositories(:rhel_6_x86_64_composite_view_version_1)

      @content_json1 = product_hash(@product1, @repo1, 'foo')
      @content_json2 = product_hash(@product2, @repo2, 'bar')
    end
  end

  class ProductContentFinderActivationKeyTest < ProductContentFinderTestBase
    def setup
      super
      @key = ActivationKey.new(:organization => @product1.organization)
      Katello::Resources::Candlepin::Product.expects(:all).returns([@content_json1, @content_json2])
    end

    def test_all
      pcf = Katello::ProductContentFinder.new(:consumable => @key)
      product_content = pcf.product_content

      assert product_content.any? { |pc| pc.content.id == @repo1.content_id }
      assert product_content.any? { |pc| pc.content.id == @repo2.content_id }
    end

    def test_match_subs
      @key.expects(:products).returns([@product1])

      pcf = Katello::ProductContentFinder.new(:consumable => @key, :match_subscription => true)
      product_content = pcf.product_content

      assert product_content.any? { |pc| pc.content.id == @repo1.content_id }
      refute product_content.any? { |pc| pc.content.id == @repo2.content_id }
    end

    def test_match_environments
      @key.environment = @repo2_cv.environment
      @key.content_view = @repo2_cv.content_view

      pcf = Katello::ProductContentFinder.new(:consumable => @key, :match_environment => true)
      product_content = pcf.product_content

      refute product_content.any? { |pc| pc.content.id == @repo1.content_id }
      assert product_content.any? { |pc| pc.content.id == @repo2.content_id }
    end
  end
end
