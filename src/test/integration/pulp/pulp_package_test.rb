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


module TestPulpPackageBase
  include RepositoryHelper

  def setup
    @resource = Resources::Pulp::Package
    VCR.insert_cassette('pulp_package')
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestPulpPackage < MiniTest::Unit::TestCase
  include TestPulpPackageBase

  def self.before_suite
    RepositoryHelper.create_and_sync_repo
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def test_package_path
    path = @resource.package_path
    assert_match("/api/packages/", path)
  end

  def test_all
    response = @resource.all
    assert response.length > 0
    assert response.select { |pack| pack['name'] == 'cheetah' }.length > 0
  end

  def test_find
    response = @resource.search('cheetah')
    response = @resource.find(response.first['id'])
    assert response.length > 0
    assert response['name'] == 'cheetah'
  end

  def test_search
    response = @resource.search('cheetah')
    assert response.length > 0
    assert response.first['name'] == 'cheetah'
  end

  def test_name_search
    response = @resource.name_search('cheetah')
    assert response.length > 0
    assert response.include?('cheetah')
  end

  def test_dep_solve
    response = @resource.dep_solve(['cheetah', 'lion'], [RepositoryHelper.repo_id])
    assert response.length > 0
  end

end
