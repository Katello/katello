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
  class OrganizationAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin'))
      @org = @acme_corporation
    end

    def test_promotion_paths
      assert_equal(@org.promotion_paths, @org.readable_promotion_paths)
    end

    def test_editable?
      assert @org.editable?
    end

    def test_manifest_importable?
      assert @org.manifest_importable?
    end

    def test_subscriptions_readable?
      assert @org.subscriptions_readable?
    end
  end

  class OrganizationAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted'))
      @org = @acme_corporation
    end

    def def_class_creatable?
      refute Organization.creatable?
    end

    def test_read_promotion_paths
      assert_empty @org.readable_promotion_paths
    end

    def test_read_promotion_paths_one
      environment = katello_environments(:staging_path1)
      setup_current_user_with_permissions(:name => "view_lifecycle_environments",
                                          :search => "name=\"#{environment.name}\"")

      refute_equal(@org.promotion_paths, @org.readable_promotion_paths)
      assert_equal(1, @org.readable_promotion_paths.size)
    end

    def test_promotable_promotion_paths_one
      environment = katello_environments(:staging_path1)
      setup_current_user_with_permissions(:name => "promote_or_remove_content_views_to_environments",
                                          :search => "name=\"#{environment.name}\"")

      refute_equal(@org.promotion_paths, @org.promotable_promotion_paths)
      assert_equal(1, @org.promotable_promotion_paths.size)
    end

    def test_manifest_importable?
      refute @org.manifest_importable?
    end

    def test_subscriptions_readable?
      refute @org.subscriptions_readable?
    end
  end
end
