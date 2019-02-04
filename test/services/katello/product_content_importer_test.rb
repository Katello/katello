require 'katello_test_helper'

module Katello
  class ProductContentImporterTest < ::ActiveSupport::TestCase
    def setup
      @fedora = katello_products(:empty_product)
      @redhat = katello_products(:empty_redhat)
      @product_content = [{
        "content" => {
          "id" => "4010",
          "type" => "file",
          "name" => "foo",
          "contentUrl" => "/content/dist/rhel/server/6/$releasever/$basearch/satellite/5.7/iso"
        },
        "enabled" => false
      }]
      @service = ProductContentImporter.new
    end

    def test_import_update
      @service.add_product_content(@fedora, @product_content)
      @service.import

      assert_equal 1, @fedora.contents.count
      assert_equal @product_content[0]['content']['id'], @fedora.contents.first.cp_content_id

      assert_equal 1, @fedora.product_contents.count
      refute @fedora.reload.product_contents.first.enabled
      assert_equal 'foo', @fedora.contents.first.name

      @product_content.first['enabled'] = true
      @product_content.first['content']['name'] = 'bar'

      @service = ProductContentImporter.new
      @service.add_product_content(@fedora, @product_content)
      @service.import

      @fedora.reload
      assert_equal 1, @fedora.contents.count
      assert_equal 1, @fedora.product_contents.count
      assert @fedora.reload.product_contents.first.enabled
      assert_equal 'bar', @fedora.contents.first.name
    end

    def test_import_missing_prod_content
      content = Katello::Content.create!(:cp_content_id => @product_content[0]['content']['id'], :organization_id => @fedora.organization.id)
      @service.add_product_content(@fedora, @product_content)
      @service.import

      @fedora.reload
      assert_equal 1, @fedora.contents.size
      assert_equal content, @fedora.contents[0]
      assert_equal 1, ::Katello::Content.where(:cp_content_id => content.cp_content_id).count
    end

    def test_import_duplicate_content
      @service.add_product_content(@fedora, @product_content)
      @service.add_product_content(@redhat, @product_content)
      @service.import

      assert_equal 1, @fedora.product_contents.count
      assert_equal 1, @redhat.product_contents.count

      assert_equal @fedora.contents, @redhat.contents
    end
  end
end
