require 'models/authorization/authorization_base'

module Katello
  class ProductAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin').id)
      @prod = @fedora
      @org = @acme_corporation
    end

    def test_readable
      refute_empty Product.readable
    end

    def test_editable
      refute_empty Product.editable
    end

    def test_syncable
      refute_empty Product.syncable
    end

    def test_deletable
      refute_empty Product.deletable
    end

    def test_readable?
      assert @prod.readable?
    end

    def test_syncable?
      assert @prod.syncable?
    end

    def test_editable?
      assert @prod.editable?
    end

    def test_deletable?
      product = Product.find(katello_products(:empty_product).id)
      assert product.deletable?
    end

    def test_readable_repositories
      refute_empty Product.readable_repositories
    end

    def test_readable_repositories_with_ids
      refute_empty Product.readable_repositories([@fedora_17_x86_64.id])
    end
  end

  class ProductAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted').id)
      @prod = @fedora
      @org = @acme_corporation
    end

    def test_readable
      assert_empty Product.readable
    end

    def test_editable
      assert_empty Product.editable
    end

    def test_syncable
      assert_empty Product.syncable
    end

    def test_deletable
      assert_empty Product.deletable
    end

    def test_readable?
      refute @prod.readable?
    end

    def test_syncable?
      refute @prod.syncable?
    end

    def test_editable?
      refute @prod.editable?
    end

    def test_deletable?
      refute @prod.deletable?
    end

    def test_readable_repositories
      assert_empty Product.readable_repositories
    end

    def test_readable_repositories_with_ids
      assert_empty Product.readable_repositories([Repository.first.id])
    end

    def test_readable_repositories_with_search
      repo = @fedora_17_x86_64
      setup_current_user_with_permissions({ :name => "view_products",
                                            :search => "name=\"#{repo.product.name}\"" })

      assert_equal([repo], Product.readable_repositories([repo.id]))
      assert_empty(Product.readable_repositories(
          [Repository.joins(:root).where("#{RootRepository.table_name}.product_id != ?", Katello::Product.readable.pluck(:id)).first]))
    end
  end
end
