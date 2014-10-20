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

require 'katello_test_helper'

module Katello
  class LocationTest < ActiveSupport::TestCase

    def test_location_create
      loc = Location.create!(:name => "FOO")
      assert_includes loc.ignore_types, ::ConfigTemplate.name
      assert_includes loc.ignore_types, ::Hostgroup.name
    end

    def test_default_destroy
      loc = Location.default_location

      refute_nil loc
      loc.destroy
      refute_empty Location.where(:id => loc.id)
      refute_empty loc.errors.messages
    end

    def test_update_katello_default
      loc = Location.default_location
      loc.katello_default = false

      assert_raises(RuntimeError) do
        loc.save!
      end
    end

  end
end
