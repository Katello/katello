# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'rubygems'
require 'minitest/autorun'
require 'test/integration/pulp/vcr_pulp_setup'
require 'test/integration/pulp/helpers/repository_helper'


module TestPulpPackageGroupCategoryBase
  include RepositoryHelper

  def setup
    @resource = Resources::Pulp::PackageGroupCategory
    VCR.insert_cassette('pulp_package_group_category')
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestPulpPackageGroupCategory < MiniTest::Unit::TestCase
  include TestPulpPackageGroupCategoryBase

  def self.before_suite
    RepositoryHelper.create_and_sync_repo
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def test_path
    path = @resource.path(RepositoryHelper.repo_id)
    assert_match("/api/repositories/" + RepositoryHelper.repo_id + "/packagegroupcategories/", path)
  end

  def test_all
    response = @resource.all(RepositoryHelper.repo_id)
    assert response.length > 0
    assert response.key?('all')
  end

end
