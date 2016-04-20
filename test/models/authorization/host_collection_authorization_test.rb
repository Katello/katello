require 'models/authorization/authorization_base'

module Katello
  class HostCollectionAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin').id)
      @host_collection = HostCollection.find(katello_host_collections(:simple_host_collection).id)
    end

    def test_readable
      refute_empty HostCollection.readable
    end

    def test_creatable
      refute_empty HostCollection.creatable
    end

    def test_editable
      refute_empty HostCollection.editable
    end

    def test_deletable
      refute_empty HostCollection.deletable
    end

    def test_host_collection_readable?
      assert @host_collection.readable?
    end

    def test_host_collection_creatable?
      assert @host_collection.creatable?
    end

    def test_host_collection_editable?
      assert @host_collection.editable?
    end

    def test_host_collection_deletable?
      assert @host_collection.deletable?
    end
  end

  class HostCollectionAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted').id)
      @host_collection = HostCollection.find(katello_host_collections(:simple_host_collection).id)
    end

    def test_readable
      assert_empty HostCollection.readable
    end

    def test_creatable
      assert_empty HostCollection.creatable
    end

    def test_editable
      assert_empty HostCollection.editable
    end

    def test_deletable
      assert_empty HostCollection.deletable
    end

    def test_host_collection_readable?
      refute @host_collection.readable?
    end

    def test_host_collection_creatable?
      refute @host_collection.creatable?
    end

    def test_host_collection_editable?
      refute @host_collection.editable?
    end

    def test_host_collection_deletable?
      refute @host_collection.deletable?
    end
  end
end
