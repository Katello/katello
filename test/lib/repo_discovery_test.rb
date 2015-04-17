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
  class FileRepoDiscoveryTest < ActiveSupport::TestCase
    def test_run
      base_url = "file://#{Katello::Engine.root}/test/fixtures/"
      crawled = []
      found = []
      to_follow = [base_url]
      rd = RepoDiscovery.new(base_url, crawled, found, to_follow)

      rd.run(to_follow.shift)
      assert_equal 1, rd.crawled.size
      refute_empty rd.to_follow
      assert_empty rd.found
      assert_equal rd.crawled.first, "#{Katello::Engine.root}/test/fixtures/"
    end
  end
end
