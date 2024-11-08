require 'katello_test_helper'

module Katello
  class ProductContentFinderTestBase < ActiveSupport::TestCase
    def setup
      @product1 = katello_products(:fedora)
      @product2 = katello_products(:redhat)
      @product3 = katello_products(:debian)

      @repo1 = katello_repositories(:fedora_17_x86_64)
      @repo2 = katello_repositories(:rhel_7_x86_64)
      @repo2_cv = katello_repositories(:rhel_6_x86_64_composite_view_version_1)
      @repo3 = katello_repositories(:debian_10_amd64)
      @repo4 = katello_repositories(:debian_10_amd64_dev)

      #@repo1's content is already in fixtures
      [@repo2].each do |repo|
        content = Katello::Content.find_by(cp_content_id: repo.content_id, organization_id: repo.product.organization_id)

        FactoryBot.create(:katello_product_content, content: content, product: @product1)
      end
    end
  end

  class ProductContentFinderActivationKeyTest < ProductContentFinderTestBase
    def setup
      super
      @key = katello_activation_keys(:simple_key)
    end

    def test_all
      pcf = Katello::ProductContentFinder.new(:consumable => @key)
      product_content = pcf.product_content

      assert product_content.any? { |pc| pc.content.cp_content_id == @repo1.content_id }
      assert product_content.any? { |pc| pc.content.cp_content_id == @repo2.content_id }
      assert product_content.any? { |pc| pc.content.cp_content_id == @repo3.content_id }
      refute product_content.any? { |pc| pc.content.cp_content_id == @repo4.content_id }
    end

    def test_match_subs
      @key.expects(:products).returns([@product1, @product3])

      pcf = Katello::ProductContentFinder.new(:consumable => @key, :match_subscription => true)
      product_content = pcf.product_content

      assert product_content.any? { |pc| pc.content.cp_content_id == @repo1.content_id }
      refute product_content.any? { |pc| pc.content.cp_content_id == @repo2.content_id }
      assert product_content.any? { |pc| pc.content.cp_content_id == @repo3.content_id }
      refute product_content.any? { |pc| pc.content.cp_content_id == @repo4.content_id }
    end

    def test_match_environments
      cves = ::Katello::ContentViewEnvironment.where(environment_id: @repo2_cv.environment,
                                                      content_view_id: @repo2_cv.content_view)

      @key.update!(content_view_environments: cves)

      Katello::Repository.where(:root => Katello::RootRepository.where(:content_id => @repo1.content_id),
                                :content_view_version_id => @key.content_view.version(@key.environment)).destroy_all

      pcf = Katello::ProductContentFinder.new(:consumable => @key, :match_environment => true)
      product_content = pcf.product_content

      refute product_content.any? { |pc| pc.content.cp_content_id == @repo1.content_id }
      assert product_content.any? { |pc| pc.content.cp_content_id == @repo2.content_id }
    end
  end

  class ProductContentFinderHostSubscriptionTest < ProductContentFinderActivationKeyTest
    def setup
      super
      @key = katello_subscription_facets(:one)
    end

    def test_match_environments
      repo5 = katello_repositories(:debian_10_amd64_composite_view_version_1)
      cves = ::Katello::ContentViewEnvironment.where(environment_id: @repo2_cv.environment,
                                                      content_view_id: @repo2_cv.content_view)

      @key.stubs(:content_view_environments).returns(cves)

      #Katello::Repository.where(:root => Katello::RootRepository.where(:content_id => @repo1.content_id),
      #                          :content_view_version_id => @key.content_view.version(@key.environment)).destroy_all

      pcf = Katello::ProductContentFinder.new(:consumable => @key, :match_environment => true)
      product_content = pcf.product_content

      refute product_content.any? { |pc| pc.content.cp_content_id == @repo1.content_id }
      assert product_content.any? { |pc| pc.content.cp_content_id == @repo2.content_id }
      refute product_content.any? { |pc| pc.content.cp_content_id == @repo3.content_id }
      refute product_content.any? { |pc| pc.content.cp_content_id == @repo4.content_id }
      assert product_content.any? { |pc| pc.content.cp_content_id == repo5.content_id }
    end
  end
end
