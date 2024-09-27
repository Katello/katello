require 'katello_test_helper'

module Katello
  class ProductContentTest < ActiveSupport::TestCase
    def setup
      @content_id = 'somecontent-123'
      @product = katello_products(:redhat)
      @content = FactoryBot.create(:katello_content, cp_content_id: @content_id, :organization_id => @product.organization_id)
      @product_content = FactoryBot.create(:katello_product_content, content: @content, product: @product)
    end

    def test_no_duplicate_content_ids
      assert_raise ActiveRecord::RecordNotUnique do
        FactoryBot.create(:katello_product_content, content: @content, product: @product)
      end
    end

    def test_no_nil_product
      assert_raise ActiveRecord::NotNullViolation do
        FactoryBot.create(:katello_product_content, content: @content, product: nil)
      end
    end

    def test_no_nil_content
      assert_raise ActiveRecord::NotNullViolation do
        FactoryBot.create(:katello_product_content, content: nil, product: @product)
      end
    end

    def test_repositories
      assert_empty @product_content.repositories

      repo = katello_repositories(:fedora_17_x86_64)
      repo.root.update!(product: @product, content_id: @content_id)

      assert_includes @product_content.repositories, repo

      @product_content.repositories.each do |repository|
        assert repository.in_default_view?
        assert_equal @product_content.product, repository.product
      end
    end

    def test_enabled
      assert_includes Katello::ProductContent.all, @product_content
      refute_includes Katello::ProductContent.enabled(@product.organization), @product_content

      root = FactoryBot.create(:katello_root_repository, :product => @product, :content_id => @content_id)
      FactoryBot.create(:katello_repository, :root => root, :environment_id => @product.organization.library.id,
        :content_view_version_id => @product.organization.default_content_view.versions.first.id)

      assert_includes Katello::ProductContent.enabled(@product.organization), @product_content
    end

    def test_enabled_value_from_candlepin
      ::Katello::Resources::Candlepin::Product.expects(:get).returns(
        [
          {
            'productContent' => [
              {
                'content' => {
                  'id' => @content_id,
                },
                'enabled' => true,
              },
            ],
          },
        ]
      )
      result = @product_content.enabled_value_from_candlepin
      assert result
    end

    def test_set_enabled_from_candlepin!
      @product_content.expects(:enabled_value_from_candlepin).returns(true)
      @product_content.expects(:enabled).returns(false)
      @product_content.expects(:update!).with(:enabled => true)
      @product_content.set_enabled_from_candlepin!
    end

    def test_set_enabled_from_candlepin_no_change
      @product_content.expects(:enabled_value_from_candlepin).returns(true)
      @product_content.expects(:enabled).returns(true)
      @product_content.expects(:update!).never
      @product_content.set_enabled_from_candlepin!
    end

    def test_redhat
      refute_includes Katello::ProductContent.redhat, katello_product_contents(:fedora_17_x86_64_content)
      assert_includes Katello::ProductContent.redhat, @product_content
    end

    def test_displayable
      @content.update(content_type: ::Katello::Repository::CANDLEPIN_DOCKER_TYPE)
      refute_includes ProductContent.displayable, @product_content

      @content.update(content_type: 'arbitrary type')
      assert_includes ProductContent.displayable, @product_content
    end

    def test_search_name
      assert_includes Katello::ProductContent.search_for("name = #{@content.name}"), @product_content
    end

    def test_search_label
      assert_includes Katello::ProductContent.search_for("label = #{@content.label}"), @product_content
    end

    def test_search_product_name
      assert_includes Katello::ProductContent.search_for("product_name = \"#{@product.name}\""), @product_content
    end

    def test_search_product_id
      assert_includes Katello::ProductContent.search_for("product_id = \"#{@product.id}\""), @product_content
    end

    def test_search_content_label
      assert_includes Katello::ProductContent.search_for("content_label = #{@content.label}"), @product_content
    end
  end
end
