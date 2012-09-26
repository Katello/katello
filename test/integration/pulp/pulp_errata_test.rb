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


module TestPulpErrataBase

  def setup
    @resource = Resources::Pulp::Errata
    VCR.insert_cassette('pulp_errata')
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestPulpErrata < MiniTest::Unit::TestCase
  include TestPulpErrataBase

  def self.before_suite
    RepositoryHelper.create_and_sync_repo
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def test_errata_path
    path = @resource.errata_path
    assert_match("/api/errata/", path)
  end

  def test_find
    response = @resource.find("RHEA-2010:0002")
    assert response.length > 0
    assert response['id'] == 'RHEA-2010:0002'
  end

  def test_filter
    response = @resource.filter({ :type => "security" })
    assert response.length > 0
    assert response.select { |errata| errata['id'] == "RHEA-2010:0002" }.length > 0
  end

end
