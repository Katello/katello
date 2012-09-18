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


module TestPulpDistributionBase
  include RepositoryHelper

  def setup
    @resource = Resources::Pulp::Distribution
    VCR.insert_cassette('pulp_distribution')
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestPulpDistribution < MiniTest::Unit::TestCase
  include TestPulpDistributionBase

  def self.before_suite
    RepositoryHelper.create_and_sync_repo
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def test_dist_path
    path = @resource.dist_path
    assert_match("/api/distributions/", path)
  end

  def test_find
    repo = RepositoryHelper.repo_resource.find(RepositoryHelper.repo_id)
    response = @resource.find(repo['distributionid'].first)
    assert response.length > 0
  end

end
