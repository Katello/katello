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


module TestPulpTaskBase
  include RepositoryHelper

  def setup
    @resource = Resources::Pulp::Task
    VCR.insert_cassette('pulp_task')
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestPulpTask < MiniTest::Unit::TestCase
  include TestPulpTaskBase

  def self.before_suite
    RepositoryHelper.create_and_sync_repo
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def test_path
    path = @resource.path
    assert_match("/api/tasks/", path)
  end

  def test_path_with_task_id
    path = @resource.path(RepositoryHelper.task['id'])
    assert_match("/api/tasks/" + RepositoryHelper.task['id'], path)
  end

  def test_find
    response = @resource.find([RepositoryHelper.task['id']])
    assert response.length > 0
    assert response.first['id'] == RepositoryHelper.task['id']
  end

  def test_cancel
    response = @resource.cancel(RepositoryHelper.task['id'])
    assert response.length > 0
  end

  def test_destroy
    response = @resource.destroy(RepositoryHelper.task['id'])
    assert response['id'] == RepositoryHelper.task['id']
  end

end
