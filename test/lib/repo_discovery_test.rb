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

    rd = RepoDiscovery.new(base_url)
    found = []
    add_proc = lambda{|url| found << url}
    continue_proc = lambda{true}

    found_final = rd.run(add_proc, continue_proc)
    assert_equal  found, found_final  #validate that final list equals incremental list
    assert_equal 1, found.size
    assert_equal found.first, base_url + 'test_repos/zoo'
  end

end
end
