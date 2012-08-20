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


class TestPulpPing < MiniTest::Unit::TestCase
  def setup
    @resource = Resources::Pulp::PulpPing
    VCR.insert_cassette('pulp_ping')
  end

  def teardown
    VCR.eject_cassette
  end

  def test_ping
    response = @resource.ping()
    assert response.length > 0
  end
end
