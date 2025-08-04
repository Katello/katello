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

    def test_debian_return_only_one_content_id_for_the_same_library_instance
      repo_dev = katello_repositories(:debian_10_dev_view)
      repo_test = katello_repositories(:debian_10_test_view)
      cves = ::Katello::ContentViewEnvironment.where(
        environment_id: [repo_dev.environment_id, repo_test.environment_id],
        content_view_version_id: [repo_dev.content_view_version_id, repo_test.content_view_version_id])

      @key.stubs(:content_view_environments).returns(cves)
      pcf = Katello::ProductContentFinder.new(:consumable => @key, :match_environment => true)
      product_content = pcf.product_content

      # repo_dev and repo_test have the same library instance
      # ensure that only one of the repos is in the product content
      refute product_content.any? { |pc| pc.content.cp_content_id == repo_test.content_id }
      assert product_content.any? { |pc| pc.content.cp_content_id == repo_dev.content_id }

      # Assert that only one product_content item is returned
      assert_equal 1, product_content.length, "Expected only one product_content item to be returned"

      # Assert that there is only one unique content_id in product_content
      unique_content_ids = product_content.map { |pc| pc.content.cp_content_id }.uniq
      assert_equal 1, unique_content_ids.length, "Expected only one unique content_id in product_content"
    end
  end
end
