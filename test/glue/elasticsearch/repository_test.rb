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
  class RepositoryTest < ActiveSupport::TestCase

    def self.before_suite
      disable_glue_layers(["Pulp"], ["Package", "Repository"])
    end

    def setup
      Package.stubs(:create_index)


      cv = ContentView.new()
      cv.stubs(:default?).returns(false)

      @repo = Repository.new(:pulp_id => "abcrepo")
      @repo.stubs(:content_view).returns(cv)
    end

    def test_index_packages
      @repo.stubs(:package_ids).returns([1,2,3])
      @repo.stubs(:indexed_package_ids).returns([1,2,5])
      Package.expects(:add_indexed_repoid).once.with([3], 'abcrepo')
      Package.expects(:remove_indexed_repoid).once.with([5], 'abcrepo')
      @repo.index_packages
    end

  end
end
