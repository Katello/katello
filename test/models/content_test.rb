require 'katello_test_helper'

module Katello
  class ContentTest < ActiveSupport::TestCase
    def setup
      @content = katello_contents(:some_content)
      @rhel_content = katello_contents(:rhel_content)
    end

    def test_product_search
      assert_include Katello::Content.search_for("product_name = #{@content.products.first.name}"), @content
    end

    def test_update_repo_name
      repo = katello_repositories(:rhel_7_x86_64)
      repo.root.update(:content_id => @rhel_content.cp_content_id)

      @rhel_content.name = "FOOBAR"
      @rhel_content.save!

      assert_includes repo.reload.name, "FOOBAR"
    end

    def test_import_all
      org_products = Organization.all.collect do |org|
        org.products.where.not(cp_id: nil).map do |cp_product|
          {
            "id" => cp_product.cp_id,
            "productContent" => [
              {
                "content" => {
                  "id" => SecureRandom.uuid,
                  "type" => "file",
                  "name" => "import_all_content",
                  "contentUrl" => "/content/dist/rhel/server/6/$releasever/$basearch/satellite/5.7/iso"
                },
                "enabled" => false
              }
            ]
          }
        end
      end
      Katello::ProductContentImporter.any_instance.stubs(:content_exists?).returns(false)
      Katello::Resources::Candlepin::Product.stubs(:all).returns(*org_products)

      Katello::Content.import_all

      contents = Katello::Content.where(name: 'import_all_content')

      assert contents.size > 0
      assert_equal contents.size, org_products.flatten.flatten.size
    end

    def test_can_update_url
      fixtures = [
        { from: '/content/rhel/x64', to: '/content/foo', expected_result: true },
        { from: '/content/rhel/$aaa/$bbb/', to: '/content/foo/$bbb/$aaa', expected_result: true },
        { from: '/content/rhel/$aaa/$bbb/', to: '/content/foo/xxxx-$bbb/yyyy-$aaa', expected_result: true },
        { from: '/content/rhel/$aaa/$bbb', to: '$aaa/content/$bbb', expected_result: true },
        { from: '/content/rhel/$aaa', to: '/content/foo', expected_result: false },
        { from: '/content/rhel/$aaa', to: '/content/$bbb', expected_result: false }
      ]
      fixtures.each do |fixture|
        @content.content_url = fixture[:from]
        fail_message = "comparing #{fixture[:from]} to #{fixture[:to]}. expected_result = #{fixture[:expected_result]}"
        assert_equal(fixture[:expected_result], @content.can_update_to_url?(fixture[:to]), fail_message)
      end
    end
  end
end
