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
  class HostCollectionAuthorizationAdminTest < AuthorizationTestBase

    def setup
      super
      User.current = User.find(users('admin'))
      @host_collection = HostCollection.find(katello_host_collections(:simple_host_collection))
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
    
    def test_key_readable?
      assert @host_collection.readable?
    end

    def test_key_creatable?
      assert @host_collection.creatable?
    end

    def test_key_editable?
      assert @host_collection.editable?
    end

    def test_key_deletable?
      assert @host_collection.deletable?
    end
  end

  class HostCollectionAuthorizationNoPermsTest < AuthorizationTestBase

    def setup
      super
      User.current = User.find(users('restricted'))
      @host_collection = HostCollection.find(katello_host_collections(:simple_host_collection))
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
   
    def test_key_readable?
      refute @host_collection.readable?
    end

    def test_key_creatable?
      refute @host_collection.creatable?
    end

    def test_key_editable?
      refute @host_collection.editable?
    end

    def test_key_deletable?
      refute @host_collection.deletable?
    end

  end
end
