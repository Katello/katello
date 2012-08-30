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
require 'test/integration/pulp/helpers/filter_helper'
require 'active_support/core_ext/time/calculations'


module TestPulpRepositoryBase
  include RepositoryHelper

  def setup
    @resource = Resources::Pulp::Repository
    VCR.insert_cassette('pulp_repository')
  end

  def teardown
    VCR.eject_cassette
  end

end


class TestPulpRepositoryCreate < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase

  def teardown
    RepositoryHelper.destroy_repo
    super
  end

  def test_create
    response = RepositoryHelper.create_repo
    assert response['id'] == RepositoryHelper.repo_id
  end
end


class TestPulpRepository < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase

  def self.before_suite
    FilterHelper.create_filter
  end

  def self.after_suite
    FilterHelper.destroy_filter
  end

  def setup
    super
    RepositoryHelper.create_repo
  end

  def teardown
    RepositoryHelper.destroy_repo
    super
  end

  def test_repository_path
    path = @resource.repository_path
    assert_match("/api/repositories/", path)
  end

  def test_discovery
    response = @resource.start_discovery(RepositoryHelper.repo_url, 'yum')
    assert response.length > 0
  end

  def test_find
    response = @resource.find(RepositoryHelper.repo_id)
    assert response["name"] == RepositoryHelper.repo_id
  end

  def test_find_all
    response = @resource.find_all([RepositoryHelper.repo_id])
    assert response.select { |repo| repo["id"] == RepositoryHelper.repo_id }.length > 0
  end

  def test_all
    response = @resource.all()
    assert response.length > 0
    assert response.select { |r| r["name"] == RepositoryHelper.repo_id }.length > 0
  end

  def test_update
    response = @resource.update(RepositoryHelper.repo_id, { :name => "updated_" + RepositoryHelper.repo_id })
    assert response.length > 0
    assert response["name"] == "updated_" + RepositoryHelper.repo_id
  end

  def test_update_schedule
    response = @resource.update_schedule(RepositoryHelper.repo_id, "R1/" << Time.now.advance(:years => 1).iso8601 << "/P1D")
    assert JSON.parse(response)["id"] == RepositoryHelper.repo_id
    @resource.delete_schedule(RepositoryHelper.repo_id)
  end

  def test_delete_schedule
    @resource.update_schedule(RepositoryHelper.repo_id, "R1/" << Time.now.advance(:years => 1).iso8601 << "/P1D")
    response = @resource.delete_schedule(RepositoryHelper.repo_id)
    assert JSON.parse(response)["id"] == RepositoryHelper.repo_id
  end

  def test_add_filters
    response = @resource.add_filters(RepositoryHelper.repo_id, [FilterHelper.filter_id])
    assert response == "true"
  end

  def test_remove_filters
    response = @resource.remove_filters(RepositoryHelper.repo_id, [FilterHelper.filter_id])
    assert response == "true"
  end

  def test_destroy
    response = @resource.destroy(RepositoryHelper.repo_id)
    assert response == 202
  end
end


class TestPulpRepositoryRequiresSync < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase

  def self.before_suite
    RepositoryHelper.create_and_sync_repo
  end

  def self.after_suite
    RepositoryHelper.destroy_repo
  end

  def test_packages
    response = @resource.packages(RepositoryHelper.repo_id)
    assert response.length > 0
  end

  def test_packages_by_name
    response = @resource.packages_by_name(RepositoryHelper.repo_id, "cheetah")
    assert response.length > 0
    assert response.select { |r| r["name"] == "cheetah" }.length > 0
  end

  def test_packages_by_nvre
    response = @resource.packages_by_nvre(RepositoryHelper.repo_id, "cheetah", "0.3", "0.8", "")
    assert response.length > 0
    assert response.select { |r| r["name"] == "cheetah" }.length > 0
  end

  def test_errata
    response = @resource.errata(RepositoryHelper.repo_id)
    assert response.length > 0
  end

  def test_errata_with_filter
    response = @resource.errata(RepositoryHelper.repo_id, { :type => 'security' })
    assert response.length > 0
    assert response.select { |errata| errata['id'] == "RHEA-2010:0002" }.length > 0
  end

  def test_distributions
    response = @resource.distributions(RepositoryHelper.repo_id)
    assert response.kind_of?(Array)
  end

  def test_sync_history
    response = @resource.sync_history(RepositoryHelper.repo_id)
    assert response.length > 0
  end

  def test_add_packages
    response = @resource.add_packages(RepositoryHelper.repo_id, [])
    assert response == "[[], 0]"
  end

  def test_add_errata 
    response = @resource.add_errata(RepositoryHelper.repo_id, ["RHEA-2010:0002"])
    assert response == "[]"
  end

  def test_add_distribution
    response = @resource.add_distribution(RepositoryHelper.repo_id, "ks-Test Family-TestVariant-16-x86_64")
    assert response == "true"
  end
end


class TestPulpRepositorySync < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase
  
  def setup
    super
    VCR.eject_cassette
    VCR.insert_cassette('pulp_repository_sync')
    RepositoryHelper.create_repo
  end

  def teardown
    RepositoryHelper.destroy_repo
    super
  end

  def test_sync_repo
    response = @resource.sync(RepositoryHelper.repo_id)
    RepositoryHelper.set_task(response)
    assert response.length > 0
    assert response["method_name"] == "_sync"
  end

  def test_sync_status
    RepositoryHelper.sync_repo
    response = @resource.sync_status(RepositoryHelper.repo_id)
    assert response.length > 0
    assert response.first['id'] == RepositoryHelper.task['id']
    RepositoryHelper.set_task(response)
  end

  def test_generate_metadata
    response = @resource.generate_metadata(RepositoryHelper.repo_id)
    RepositoryHelper.set_task(response)
    assert response.length > 0
    assert response["method_name"] == "_generate_metadata"
  end

end


class TestPulpRepositoryClone < MiniTest::Unit::TestCase
  include TestPulpRepositoryBase

  def setup
    super
    RepositoryHelper.create_and_sync_repo
    @clone_name = RepositoryHelper.repo_id + "_clone"
  end

  def teardown
    RepositoryHelper.destroy_repo(@clone_name)
    RepositoryHelper.destroy_repo
    super
  end

  def test_clone_repo
    RepositoryHelper.destroy_repo(@clone_name)
    from_repo = OpenStruct.new({ :pulp_id => RepositoryHelper.repo_id })
    to_repo = OpenStruct.new({ :pulp_id => @clone_name, :name => @clone_name })
    response = @resource.clone_repo(from_repo, to_repo)
    RepositoryHelper.set_task(response)
    assert response.length > 0
    assert response["args"].include?(@clone_name)
  end
end
