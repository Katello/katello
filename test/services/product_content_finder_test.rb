require 'katello_test_helper'

module Katello
  class ProductContentFinderTestBase < ActiveSupport::TestCase
    def setup
      @product1 = katello_products(:fedora)
      @product2 = katello_products(:redhat)

      @repo1 = katello_repositories(:fedora_17_x86_64)
      @repo2 = katello_repositories(:rhel_7_x86_64)
      @repo2_cv = katello_repositories(:rhel_6_x86_64_composite_view_version_1)

      #@repo1's content is already in fixtures
      [@repo2].each do |repo|
        content = FactoryBot.create(:katello_content,
                                    name: repo.name,
                                    label: repo.label,
                                    organization_id: repo.product.organization_id,
                                    cp_content_id: repo.content_id)

        FactoryBot.create(:katello_product_content, content: content, product: @product1)
      end
    end
  end

  class ProductContentFinderActivationKeyTest < ProductContentFinderTestBase
    def setup
      super
      @key = ActivationKey.new(:organization => @product1.organization)
    end

    def test_all
      pcf = Katello::ProductContentFinder.new(:consumable => @key)
      product_content = pcf.product_content

      assert product_content.any? { |pc| pc.content.cp_content_id == @repo1.content_id }
      assert product_content.any? { |pc| pc.content.cp_content_id == @repo2.content_id }
    end

    def test_match_subs
      @key.expects(:products).returns([@product1])

      pcf = Katello::ProductContentFinder.new(:consumable => @key, :match_subscription => true)
      product_content = pcf.product_content

      assert product_content.any? { |pc| pc.content.cp_content_id == @repo1.content_id }
      refute product_content.any? { |pc| pc.content.cp_content_id == @repo2.content_id }
    end

    def test_match_environments
      @key.environment = @repo2_cv.environment
      @key.content_view = @repo2_cv.content_view

      pcf = Katello::ProductContentFinder.new(:consumable => @key, :match_environment => true)
      product_content = pcf.product_content

      refute product_content.any? { |pc| pc.content.cp_content_id == @repo1.content_id }
      assert product_content.any? { |pc| pc.content.cp_content_id == @repo2.content_id }
    end
  end
end
