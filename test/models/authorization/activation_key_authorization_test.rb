require 'models/authorization/authorization_base'

module Katello
  class ActivationKeyAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = users('admin')
      @key = katello_activation_keys('simple_key')
    end

    def test_readable
      refute_empty ActivationKey.readable
    end

    def test_deletable
      refute_empty ActivationKey.deletable
    end

    def test_readable?
      assert @key.readable?
    end

    def test_editable?
      assert @key.editable?
    end

    def test_deletable?
      assert @key.deletable?
    end

    def test_any_editable?
      assert ActivationKey.any_editable?
    end

    def test_all_editable?
      ak = ActivationKey.find(katello_activation_keys(:library_dev_staging_view_key).id)
      assert ActivationKey.all_editable?(ak.content_view, ak.environment)
    end
  end

  class ActivationKeyAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:restricted).id)
      @key = ActivationKey.find(katello_activation_keys('simple_key').id)
    end

    def test_deletable
      assert_empty ActivationKey.deletable
    end

    def test_readable?
      refute @key.readable?
    end

    def test_editable?
      refute @key.editable?
    end

    def test_deletable?
      refute @key.deletable?
    end

    def test_any_editable?
      refute ActivationKey.any_editable?
    end

    def test_all_editable?
      ak = ActivationKey.find(katello_activation_keys(:library_dev_staging_view_key).id)
      refute ActivationKey.all_editable?(ak.content_view, ak.environment)
    end
  end

  class ActivationKeyAuthorizationWithPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted').id)
    end

    def test_all_editable?
      ak = ActivationKey.find(katello_activation_keys(:library_dev_staging_view_key).id)
      keys = ActivationKey.where(:content_view_id => ak.content_view_id, :environment_id => ak.environment)

      clause = keys.map { |key| "name=\"#{key.name}\"" }.join(" or ")

      setup_current_user_with_permissions({ :name => "edit_activation_keys",
                                            :search => clause })
      assert ActivationKey.all_editable?(ak.content_view, ak.environment)
    end
  end
end
