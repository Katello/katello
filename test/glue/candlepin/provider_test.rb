require 'katello_test_helper'
require 'support/candlepin/owner_support'

module Katello
  class GlueCandlepinProviderTest < ActiveSupport::TestCase
    include VCR::TestCase
    include Dynflow::Testing

    # manifests used by these tests were created from an ordinary manifest with a number of subscriptions
    # and pared down using the below script to keep this test fast and not load unnecessary data
    # https://github.com/candlepin/candlepin/blob/master/server/bin/manifest_manipulator.rb
    def setup
      set_user
      @org = CandlepinOwnerSupport.create_organization('GlueCandlepinProviderTest', 'GlueCandlepinProviderTest')
      manifest_path = File.join(::Katello::Engine.root, 'test', 'fixtures', 'files', 'manifest_small.zip')
      CandlepinOwnerSupport.import_manifest(@org.label, manifest_path)
      @provider = FactoryBot.create(:katello_provider, :redhat, organization: @org)
      @provider.import_products_from_cp

      @product = @org.products.find { |p| p.name == 'Red Hat Container Images' }
      @product_contents = @product.product_contents
    end

    def teardown
      CandlepinOwnerSupport.destroy_organization(@org)
    end

    def vcr_matches
      [:method, :path, :params]
    end

    def test_import_products
      assert_equal 2, @org.products.length
      assert_equal 2, @product_contents.length
      @product_contents.each do |pc|
        refute_nil pc.content
        assert_equal @product, pc.content.products.first
      end
    end

    def test_import_products_updates_content
      manifest_path = File.join(::Katello::Engine.root, 'test', 'fixtures', 'files', 'manifest_small_modified.zip')
      CandlepinOwnerSupport.import_manifest(@org.label, manifest_path)
      @provider.import_products_from_cp
      @org.reload

      assert_equal 3, @org.products.length # new product arrived
      assert_equal 3, @product_contents.length # new content arrived on old product

      refute_nil @product_contents.to_a.find { |pc| pc.content.name.include?('Containerz') } # content name got updated
      refute_nil @org.products.to_a.find { |p| p.name.include?('Imagez') } # product name got updated
    end
  end
end
