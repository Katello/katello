require 'models/authorization/authorization_base'

module Katello
  class ContentCredentialAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin').id)
      @content_credential = katello_gpg_keys(:fedora_gpg_key)
    end

    def test_readable
      refute_empty ContentCredential.readable
    end

    def test_editable
      refute_empty ContentCredential.editable
    end

    def test_deletable
      refute_empty ContentCredential.deletable
    end

    def test_content_credential_readable?
      assert @content_credential.readable?
    end

    def test_content_credential_editable?
      assert @content_credential.editable?
    end

    def test_content_credential_deletable?
      assert @content_credential.deletable?
    end
  end

  class ContentCredentialNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted').id)
      @content_credential = katello_gpg_keys(:fedora_gpg_key)
    end

    def test_readable
      assert_empty ContentCredential.readable
    end

    def test_editable
      assert_empty ContentCredential.editable
    end

    def test_deletable
      assert_empty ContentCredential.deletable
    end

    def test_content_credential_readable?
      refute @content_credential.readable?
    end

    def test_content_credential_editable?
      refute @content_credential.editable?
    end

    def test_content_credential_deletable?
      refute @content_credential.deletable?
    end
  end
end
