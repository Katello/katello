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
require 'test/integration/pulp/vcr_pulp_setup'


module RepositoryHelper

  @repo_url = "file://#{File.expand_path(File.dirname(__FILE__))}".gsub("pulp/helpers", "fixtures/repositories/zoo5")
  @repo_id = "integration_test_id"
  @repo_name = @repo_id
  @repo_resource = Resources::Pulp::Repository
  @task_resource = Resources::Pulp::Task

  def self.repo_name
    @repo_name
  end

  def self.repo_id
    @repo_id
  end

  def self.repo_url
    @repo_url
  end

  def self.task_resource
    @task_resource
  end

  def self.repo_resource
    @repo_resource
  end

  def self.set_task(task)
    @task = task
  end

  def self.task
    @task
  end

  def self.create_and_sync_repo
    p "Creating and Sync'ing repository."
    create_repo
    sync_repo
  end

  def self.create_repo
    repo = nil
    
    VCR.use_cassette('pulp_repository_helper') do
      repo = @repo_resource.find(@repo_id)
    end

    if !repo.nil?
      destroy_repo
    end

    VCR.use_cassette('pulp_repository_helper') do
      repo = @repo_resource.create(:id => @repo_id, :name=> @repo_name, :arch => 'noarch', :feed => @repo_url)
    end

    return repo
  rescue Exception => e
    p e
  end

  def self.sync_repo
    VCR.use_cassette('pulp_repository_helper') do
      @task = @repo_resource.sync(@repo_name)

      @task = @task_resource.cancel(@task["id"])
      while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
        @task = @task_resource.find([@task["id"]]).first
        sleep 1 # do not overload backend engines
      end
    end
  rescue Exception => e
    p e
  end

  def self.destroy_repo(id=@repo_id)
    p "Destroying Repository."

    VCR.use_cassette('pulp_repository_helper') do
      if @task
        while !(['finished', 'error', 'timed_out', 'canceled', 'reset'].include?(@task['state'])) do
          @task = @task_resource.find([@task["id"]]).first
          sleep 1 # do not overload backend engines
        end

        @task_resource.destroy(@task["id"])
        @task = nil
      end

      @repo_resource.destroy(id)
    end
  rescue Exception => e
    p "RepositoryHelper: Repository #{id} could not be destroyed."
  end

end
