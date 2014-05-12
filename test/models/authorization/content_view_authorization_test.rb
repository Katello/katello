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
  class ContentViewAuthorizationAdminTest < AuthorizationTestBase

    def setup
      super
      User.current = User.find(users('admin'))
      @view = ContentView.find(katello_content_views('acme_default'))
    end

    def test_readable
      refute_empty ContentView.readable
    end

    def test_key_readable?
      assert @view.readable?
    end

    def test_key_editable?
      assert @view.editable?
    end

    def test_key_deletable?
      assert @view.deletable?
    end

    def test_promotable?
      assert @view.promotable_or_removable?
    end
  end

  class ContentViewAuthorizationNoPermsTest < AuthorizationTestBase

    def setup
      super
      User.current = User.find(users('restricted'))
      @view = ContentView.find(katello_content_views('acme_default'))
    end

    def test_readable
      assert_empty ContentView.readable
    end

    def test_key_readable?
      refute @view.readable?
    end

    def test_key_editable?
      refute @view.editable?
    end

    def test_key_deletable?
      refute @view.deletable?
    end

    def test_promotable?
      refute @view.promotable_or_removable?
    end

    def test_promotable_perm
      cv = katello_content_views(:library_dev_staging_view)
      setup_current_user_with_permissions(:name => "promote_or_remove_content_views",
                                        :search => "name=\"#{cv.name}\"")
      assert cv.promotable_or_removable?
    end

  end
end
