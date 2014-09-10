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
  class HostgroupExtensionsTest < ActiveSupport::TestCase
    def inherited_content_source_id_with_ancestry
      root = Hostgroup.new(:name => 'AHostgroup', :content_source => smart_proxies(:puppetmaster))
      root.save

      child = Hostgroup.new(:name => 'AChild', :parent => root)
      child.save

      assert_equal smart_proxies(:puppetmaster).id, child.inherited_content_source_id
    end

    def inherited_content_source_id_without_ancestry
      root = Hostgroup.new(:name => 'AHostgroup', :content_source => smart_proxies(:puppetmaster))
      root.save

      assert_equal smart_proxies(:puppetmaster).id, root.inherited_content_source_id
    end
  end
end
