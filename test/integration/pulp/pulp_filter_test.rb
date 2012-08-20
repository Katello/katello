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


module TestPulpFilterBase
  def setup
    @resource = Resources::Pulp::Filter
    @filter_id = "integration_test_filter"
    VCR.insert_cassette('pulp_filter')
  end

  def teardown
    destroy_filter
    VCR.eject_cassette
  end

  def create_filter
    @resource.create(:id => @filter_id, :type => "blacklist", :package_list => ['cheetah'])
  rescue Exception => e
  end

  def destroy_filter
    @resource.destroy(@filter_id)
  rescue Exception => e
  end

end

class TestPulpFilterCreate < MiniTest::Unit::TestCase
  include TestPulpFilterBase

  def test_create
    response = create_filter
    assert response.length > 0
    assert response['id'] == @filter_id
  end

end

class TestPulpFilter < MiniTest::Unit::TestCase
  include TestPulpFilterBase

  def setup
    super
    create_filter
  end

  def test_path
    path = @resource.path
    assert_match("/api/filters/", path)
  end

  def test_path_with_id
    path = @resource.path(@filter_id)
    assert_match("/api/filters/" + @filter_id, path)
  end

  def test_find
    response = @resource.find(@filter_id)
    assert response.length > 0
    assert response['id'] == @filter_id
  end

  def test_destroy
    response = @resource.destroy(@filter_id)
    assert response == 200
  end

  def test_add_packages
    response = @resource.add_packages(@filter_id, ['cheetah', 'lion'])
    assert response == "true"
  end

  def test_remove_packages
    response = @resource.add_packages(@filter_id, ['cheetah', 'lion'])
    response = @resource.remove_packages(@filter_id, ['cheetah', 'lion'])
    assert response == "true"
  end

end
