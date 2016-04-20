require 'models/authorization/authorization_base'

module Katello
  class GpgKeyAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin').id)
      @key = GpgKey.find(katello_gpg_keys('fedora_gpg_key').id)
    end

    def test_readable
      refute_empty GpgKey.readable
    end

    def test_key_readable?
      assert @key.readable?
    end

    def test_key_editable?
      assert @key.editable?
    end

    def test_key_deletable?
      assert @key.deletable?
    end
  end

  class GpgKeyAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted').id)
      @key = GpgKey.find(katello_gpg_keys('fedora_gpg_key').id)
    end

    def test_readable
      assert_empty GpgKey.readable
    end

    def test_key_readable?
      refute @key.readable?
    end

    def test_key_editable?
      refute @key.editable?
    end

    def test_key_deletable?
      refute @key.deletable?
    end
  end
end
