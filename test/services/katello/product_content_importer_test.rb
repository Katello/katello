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
          "contentUrl" => "/content/dist/rhel/server/6/$releasever/$basearch/satellite/5.7/iso",
        },
        "enabled" => false,
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

    def test_import_with_changed_url
      @product_content.first['content']['contentUrl'] = '/foo/$basearch/$releasever/'
      @service.add_product_content(@fedora, @product_content)
      @service.import

      assert_equal 1, @fedora.contents.count
      assert_equal @product_content[0]['content']['id'], @fedora.contents.first.cp_content_id

      assert_equal 1, @fedora.product_contents.count
      refute @fedora.reload.product_contents.first.enabled
      assert_equal 'foo', @fedora.contents.first.name

      @product_content.first['enabled'] = true
      @product_content.first['content']['contentUrl'] = '/bar/$releasever/$basearch/'

      @service = ProductContentImporter.new
      @service.add_product_content(@fedora, @product_content)
      @service.import

      assert_equal [@product_content.first['content']['id']], @service.content_url_updated.map(&:cp_content_id)

      @product_content.first['enabled'] = true
      # bad substitution
      @product_content.first['content']['contentUrl'] = '/bar/$releasever'

      @service = ProductContentImporter.new
      @service.add_product_content(@fedora, @product_content)
      @service.import

      assert_empty(@service.content_url_updated)
    end

    def test_find_product_for_content
      cp_products = [{"id" => "590",
                      "productContent" =>
                        [{"content" =>
                            {
                              "id" => "11210",
                              "type" => "yum",
                              "label" => "codeready-builder-for-rhel-9-s390x-eus-rpms",
                              "name" => "Red Hat CodeReady Linux Builder for RHEL 9 IBM z Systems - Extended Update Support (RPMs)",
                            },
                          "enabled" => false},
                         {"content" =>
                            {"id" => "9268",
                             "type" => "yum",
                             "label" => "codeready-builder-for-rhel-8-s390x-eus-debug-rpms",
                             "name" => "Red Hat CodeReady Linux Builder for RHEL 8 IBM z Systems - Extended Update Support (Debug RPMs)",
                             },
                          "enabled" => false}]},
                     {"id" => "350", "productContent" => []},
                     {"id" => "380"}]
      prod_content_importer = Katello::ProductContentImporter.new(cp_products)
      test_product = ::Katello::Product.create(
        name: 'empty',
        organization_id: ::Organization.first.id,
        provider: ::Organization.first.anonymous_provider,
        cp_id: '590'
      )
      assert_equal test_product, prod_content_importer.find_product_for_content("11210")
      assert_nil prod_content_importer.find_product_for_content(nil)
      assert_nil prod_content_importer.find_product_for_content("")
      assert_nil prod_content_importer.find_product_for_content('350')
      assert_nil prod_content_importer.find_product_for_content('380')
    end
  end
end
