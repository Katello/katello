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
require 'test/integration/pulp/helpers/consumer_helper'
require 'active_support/core_ext/time/calculations'


module TestPulpConsumerGroupBase
  include RepositoryHelper
  include ConsumerHelper

  def setup
    @resource = Resources::Pulp::ConsumerGroup
    @consumer_group_id = "integration_test_consumer_group"
    VCR.insert_cassette('pulp_consumer_group')
  end

  def teardown
    if @task
      RepositoryHelper.task_resource.destroy(@task["id"])
    end
    VCR.eject_cassette
  end

  def create_consumer_group
    @resource.create(:id => @consumer_group_id, :description => 'Test description.', :consumerids => [])
  rescue Exception => e
    p "TestPulpConsumerGroup: ConsumerGroup #{@consumer_group_id} already existed."
  end

  def destroy_consumer_group
    @resource.destroy(@consumer_group_id)
  rescue Exception => e
    p "TestPulpConsumerGroup: No consumer_group #{@consumer_group_id} to delete."
  end

end


class TestPulpConsumerGroupCreate < MiniTest::Unit::TestCase
  include TestPulpConsumerGroupBase

  def teardown
    destroy_consumer_group
    super
  end

  def test_create
    response = create_consumer_group
    assert response['id'] == @consumer_group_id
  end
end


class TestPulpConsumerGroupDestroy < MiniTest::Unit::TestCase
  include TestPulpConsumerGroupBase

  def setup
    super
    create_consumer_group
  end

  def test_destroy
    response = @resource.destroy(@consumer_group_id)
    assert response == 200
  end

end


class TestPulpConsumerGroup < MiniTest::Unit::TestCase
  include TestPulpConsumerGroupBase

  def setup
    super
    create_consumer_group
  end

  def teardown
    destroy_consumer_group
    super
  end

  def test_path
    path = @resource.path
    assert_match('/api/consumergroups/', path)
  end

  def test_path_with_id
    path = @resource.path(@consumer_group_id)
    assert_match("/api/consumergroups/#{@consumer_group_id}/", path)
  end

  def test_find
    response = @resource.find(@consumer_group_id)
    assert response.length > 0
    assert response['id'] == @consumer_group_id
  end
end


class TestPulpConsumerGroupRequiresRepo < MiniTest::Unit::TestCase
  include TestPulpConsumerGroupBase

  def self.before_suite
    ConsumerHelper.create_consumer(true)
  end

  def self.after_suite
    ConsumerHelper.destroy_consumer
  end

  def setup
    super
    create_consumer_group
  end

  def teardown
    destroy_consumer_group
    super
  end

  def test_add_consumer
    response = @resource.add_consumer(@consumer_group_id, ConsumerHelper.consumer_id)
    assert response == "true"
    response = @resource.delete_consumer(@consumer_group_id, ConsumerHelper.consumer_id)
  end

  def test_delete_consumer
    @resource.add_consumer(@consumer_group_id, ConsumerHelper.consumer_id)
    response = @resource.delete_consumer(@consumer_group_id, ConsumerHelper.consumer_id)
    assert response == "null"
  end

  def test_install_errata
    response = @resource.install_errata(@consumer_group_id, ['RHEA-2010:0002'], Time.now.advance(:years => 1).iso8601)
    assert response.has_key?('tasks')
    assert response.has_key?('id')
  end

  def test_install_packages
    response = @resource.install_packages(@consumer_group_id, ['cheetah'], Time.now.advance(:years => 1).iso8601)
    assert response.has_key?('tasks')
    assert response.has_key?('id')
  end

  def test_uninstall_packages
    response = @resource.uninstall_packages(@consumer_group_id, ['elephant'], Time.now.advance(:years => 1).iso8601)
    assert response.has_key?('tasks')
    assert response.has_key?('id')
  end

  def test_update_packages
    response = @resource.update_packages(@consumer_group_id, ['elephant'], Time.now.advance(:years => 1).iso8601)
    assert response.has_key?('tasks')
    assert response.has_key?('id')
  end

  def test_install_package_groups
    response = @resource.install_package_groups(@consumer_group_id, ['mammals'], Time.now.advance(:years => 1).iso8601)
    assert response.has_key?('tasks')
    assert response.has_key?('id')
  end

  def test_uninstall_package_groups
    response = @resource.uninstall_package_groups(@consumer_group_id, ['mammals'], Time.now.advance(:years => 1).iso8601)
    assert response.has_key?('tasks')
    assert response.has_key?('id')
  end
end
