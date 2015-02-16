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

    def test_content_view_readable?
      assert @view.readable?
    end

    def test_content_view_editable?
      assert @view.editable?
    end

    def test_content_view_deletable?
      assert @view.deletable?
    end

    def test_content_view_publishable?
      assert @view.publishable?
    end

    def test_promotable?
      assert @view.promotable_or_removable?
    end

    def test_readable_repositories
      refute_empty ContentView.readable_repositories
    end

    def test_readable_repositories_with_ids
      refute_empty ContentView.readable_repositories([Repository.first.id])
    end

    def test_readable_products
      refute_empty ContentView.readable_products
    end

    def test_readable_products_with_ids
      refute_empty ContentView.readable_products([Product.first.id])
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

    def test_content_view_readable?
      refute @view.readable?
    end

    def test_content_view_editable?
      refute @view.editable?
    end

    def test_content_view_deletable?
      refute @view.deletable?
    end

    def test_content_view_publishable?
      refute @view.publishable?
    end

    def test_promotable?
      refute @view.promotable_or_removable?
    end

    def test_promotable_perm
      cv = katello_content_views(:library_dev_staging_view)
      refute cv.promotable_or_removable?
    end

    def test_readable_repositories
      assert_empty ContentView.readable_repositories
    end

    def test_readable_repositories_with_ids
      assert_empty ContentView.readable_repositories([Repository.first.id])
    end

    def test_readable_products
      assert_empty ContentView.readable_products
    end

    def test_readable_products_with_ids
      assert_empty ContentView.readable_products([Product.first.id])
    end

    def test_readable_products_with_search
      prod = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_composite_view_version_1)).product
      view = katello_content_views(:library_view)
      view2 = katello_content_views(:composite_view)
      setup_current_user_with_permissions(:name => "view_content_views",
                                          :search => "name=\"#{view.name}\"")

      assert_empty(ContentView.readable_products - view.products)
      assert_equal ContentView.readable_products(view2.products.pluck(:id)), [prod]
    end
  end
end
