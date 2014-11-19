#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'models/authorization/authorization_base'

module Katello
  class ActivationKeyAuthorizationAdminTest < AuthorizationTestBase

    def setup
      super
      User.current = User.find(users('admin'))
      @key = ActivationKey.find(katello_activation_keys('simple_key'))
    end

    def test_readable
      refute_empty ActivationKey.readable
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
      ak = ActivationKey.find(katello_activation_keys(:library_dev_staging_view_key))
      assert ActivationKey.all_editable?(ak.content_view, ak.environment)
    end
  end

  class ActivationKeyAuthorizationNoPermsTest  < AuthorizationTestBase

    def setup
      super
      User.current = User.find(users(:restricted))
      @key = ActivationKey.find(katello_activation_keys('simple_key'))
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
      ak = ActivationKey.find(katello_activation_keys(:library_dev_staging_view_key))
      refute ActivationKey.all_editable?(ak.content_view, ak.environment)
    end
  end

  class ActivationKeyAuthorizationAsUserTest  < AuthorizationTestBase

    def setup
      super
      User.current = User.find(users(:admin))
      @as_user = User.find(users(:restricted))
      @key = ActivationKey.find(katello_activation_keys('simple_key'))
    end

    def test_readable?
      refute @key.readable?(@as_user)
    end

    def test_editable?
      refute @key.editable?(@as_user)
    end

    def test_deletable?
      refute @key.deletable?(@as_user)
    end

    def test_any_editable?
      refute ActivationKey.any_editable?(@as_user)
    end

    def test_all_editable?
      ak = ActivationKey.find(katello_activation_keys(:library_dev_staging_view_key))
      refute ActivationKey.all_editable?(ak.content_view, ak.environment, @as_user)
    end
  end

  class ActivationKeyAuthorizationWithPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted'))
    end

    def test_all_editable?
      ak = ActivationKey.find(katello_activation_keys(:library_dev_staging_view_key))
      keys = ActivationKey.where(:content_view_id => ak.content_view_id, :environment_id => ak.environment)

      clause = keys.map { |key| "name=\"#{key.name}\"" }.join(" or ")

      setup_current_user_with_permissions(:name => "edit_activation_keys",
                                          :search => clause)
      assert ActivationKey.all_editable?(ak.content_view, ak.environment)
    end
  end
end
