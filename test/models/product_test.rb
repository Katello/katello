require File.expand_path("repository_base", File.dirname(__FILE__))

module Katello
  class ProductCreateTest < ActiveSupport::TestCase
    def setup
      super
      set_user
      @product = build(:katello_product,
                       :organization => get_organization,
                       :provider => katello_providers(:anonymous)
                      )
      @redhat_product = katello_products(:redhat)
      @promoted_product = katello_products(:fedora)
    end

    def teardown
      @product&.destroy
    end

    test_attributes :pid => '3d873b73-6919-4fda-84df-0e26bdf0c1dc'
    def test_create_with_name
      organization = get_organization
      provider = katello_providers(:anonymous)
      valid_name_list.each do |name|
        product = FactoryBot.build(
          :katello_product,
          :organization => organization,
          :provider => provider,
          :name => name
        )
        assert product.valid?, "Validation failed for create with valid name: '#{name}' length: #{name.length})"
        assert_equal name, product.name
      end
    end

    test_attributes :pid => 'f3e2df77-6711-440b-800a-9cebbbec36c5'
    def test_create_with_description
      organization = get_organization
      provider = katello_providers(:anonymous)
      valid_name_list.each do |description|
        product = FactoryBot.build(
          :katello_product,
          :organization => organization,
          :provider => provider,
          :description => description
        )
        assert product.valid?, "Validation failed for create with valid description: '#{description}' length: #{description.length})"
        assert_equal description, product.description
      end
    end

    test_attributes :pid => '95cf8e05-fd09-422e-bf6f-8b1dde762976'
    def test_create_with_label
      label = RFauxFactory.gen_alphanumeric
      product = FactoryBot.build(
        :katello_product,
        :organization => get_organization,
        :provider => katello_providers(:anonymous),
        :name => RFauxFactory.gen_utf8,
        :label => label
      )
      assert_valid product
      assert_equal label, product.label
      refute_equal label, product.name
    end

    test_attributes :pid => '76531f53-09ff-4ee9-89b9-09a697526fb1'
    def test_create_with_invalid_name
      organization = get_organization
      provider = katello_providers(:anonymous)
      invalid_name_list.each do |name|
        product = FactoryBot.build(
            :katello_product,
            :organization => organization,
            :provider => provider,
            :name => name
        )
        refute product.valid?, "Validation succeeded for create with invalid name: '#{name}' length: #{name.length})"
        assert_includes product.errors.attribute_names, :name
      end
    end

    test_attributes :pid => '30b1a737-07f1-4786-b68a-734e57c33a62'
    def test_create_with_invalid_label
      product = FactoryBot.build(
          :katello_product,
          :organization => get_organization,
          :provider => katello_providers(:anonymous),
          :label => RFauxFactory.gen_utf8
      )
      refute_valid product
      assert_includes product.errors.attribute_names, :label
    end

    test_attributes :pid => '1a9f6e0d-43fb-42e2-9dbd-e880f03b0297'
    def test_update_name
      valid_name_list.each do |name|
        @product.name = name
        assert @product.valid?, "Validation failed for update with valid name: '#{name}' length: #{name.length})"
      end
    end

    test_attributes :pid => 'c960c326-2e9f-4ee7-bdec-35a705305067'
    def test_update_description
      valid_name_list.each do |description|
        @product.description = description
        assert @product.valid?, "Validation failed for update with valid description: '#{description}' length: #{description.length})"
      end
    end

    test_attributes :pid => '3075f17f-4475-4b64-9fbd-1e41ced9142d'
    def test_update_name_to_original
      @product.save!
      original_name = @product.name
      new_name = RFauxFactory.gen_alpha
      @product.name = new_name
      @product.save!
      @product.name = original_name
      assert_valid @product
    end

    test_attributes :pid => '3eb61fa8-3524-4872-8f1b-4e88004f66f5'
    def test_update_with_invalid_name
      invalid_name_list.each do |name|
        @product.name = name
        refute @product.valid?, "Validation succeeded for update with invalid name: '#{name}' length: #{name.length})"
        assert_includes @product.errors.attribute_names, :name
      end
    end

    test_attributes :pid => '065cd673-8d10-46c7-800c-b731b06a5359'
    def test_update_label
      @product.label = RFauxFactory.gen_alpha
      @product.save!
      @product.label = RFauxFactory.gen_alpha
      refute_valid @product
      assert_includes @product.errors.attribute_names, :label
      assert_equal 'cannot be changed.', @product.errors['label'][0]
    end

    def test_enabled
      products = Product.enabled
      refute_includes products, katello_products(:empty_redhat)
      assert_includes products, @redhat_product
      assert_includes products, katello_products(:empty_product)
    end

    def test_redhat
      assert_includes Product.redhat, @redhat_product
      refute_includes Product.redhat, @promoted_product
    end

    def test_custom
      assert_includes Product.custom, @promoted_product
      refute_includes Product.custom, @redhat_product
    end

    def test_redhat?
      assert @redhat_product.redhat?
      refute @product.redhat?
    end

    def test_user_deletable?
      refute @redhat_product.user_deletable?
      assert @product.user_deletable?
      refute @promoted_product.user_deletable?
    end

    def test_search_redhat
      products = Product.search_for('redhat = true')
      assert_includes products, @redhat_product
      refute_includes products, @promoted_product
    end

    def test_search_custom
      products = Product.search_for('redhat = false')
      assert_includes products, @promoted_product
      refute_includes products, @redhat_product
    end

    def test_search_label
      products = Product.search_for("label = #{@redhat_product.label}")
      assert_includes products, @redhat_product
    end

    def test_search_description
      products = Product.search_for("description = \"#{@redhat_product.description}\"")
      assert_includes products, @redhat_product
    end

    def test_create
      assert @product.save
      refute_empty Product.where(:id => @product.id)
    end

    test_attributes :pid => '039269c5-607a-4b70-91dd-b8fed8e50cc6'
    def test_unique_name_per_organization
      @product.save!
      @product2 = build(:katello_product,
                        :organization => @product.organization,
                        :provider => @product.provider,
                        :name => @product.name,
                        :label => 'Another Label')

      refute @product2.valid?
    end

    def test_unique_label_per_organization
      @product.save!
      @product2 = build(:katello_product,
                        :organization => @product.organization,
                        :provider => @product.provider,
                        :name => 'Another Name',
                        :label => @product.label)

      refute @product2.valid?
    end

    def test_syncable_content
      products_with_syncable_repos = Product.all.select do |prod|
        prod.root_repositories.any? { |r| r.url.present? }
      end
      products = Katello::Product.syncable_content
      assert_equal products_with_syncable_repos.length, products.length
      products.each { |prod| assert prod.syncable_content? }
    end

    def test_not_used_by_other_org
      refute @redhat_product.used_by_another_org?
    end

    def test_used_by_other_orgs
      other_org = taxonomies(:organization1)
      create(:katello_product,
             :cp_id => @redhat_product.cp_id,
             :organization => other_org,
             :name => @redhat_product.name,
             :label => 'dont_label_me',
             :provider => other_org.redhat_provider)

      assert @redhat_product.used_by_another_org?
    end

    def test_subscribable_without_repos
      product = katello_products(:fedora)
      product.root_repositories = []

      assert_includes Product.subscribable, product
    end

    def test_find_product_content_by_id
      (1..2).each do |x|
        content = FactoryBot.create(:katello_content, cp_content_id: "content-#{x}", organization_id: @redhat_product.organization_id)
        FactoryBot.create(:katello_product_content, content: content, product: @redhat_product)
      end

      expected = 'content-2'
      found_content = @redhat_product.product_content_by_id(expected)

      assert_equal expected, found_content.content.cp_content_id
    end

    def test_available_content
      product = katello_products(:fedora)
      fedora = katello_repositories(:fedora_17_x86_64)
      file = katello_repositories(:generic_file)

      fedora_content = product.product_contents.to_a
      file.root.update(content_id: 2)

      content = FactoryBot.create(:katello_content, cp_content_id: file.content_id, organization_id: file.product.organization_id)
      FactoryBot.create(:katello_product_content, content: content, product: product)

      Repository.any_instance.stubs(:exist_for_environment?).returns(true)
      product.root_repositories = [fedora.root, file.root]

      assert_equal fedora_content, product.available_content.to_a
    end

    def test_audit_on_product_update
      new_product = katello_products(:fedora)
      new_product.name = 'Audit this product'
      assert_difference 'new_product.audits.count' do
        new_product.save!
      end
    end
  end
end
