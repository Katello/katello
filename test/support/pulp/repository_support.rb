#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'
require './test/support/pulp/task_support'


module RepositorySupport
  include TaskSupport

  @repo_url = "file:///var/www/test_repo"
  @repo     = nil

  def self.repo_id
    @repo.id
  end

  def self.repo
    @repo
  end

  def self.create_and_sync_repo(repo_id)
    @repo = create_repo(repo_id)
    sync_repo
  end

  def self.create_repo(repo_id)
    @repo = Repository.find(repo_id)
    @repo.relative_path = '/test_path/'
    @repo.feed = @repo_url

    @repo.create_pulp_repo
  rescue => e
  ensure
    return @repo
  end

  def self.sync_repo
    tasks = @repo.sync
    TaskSupport.wait_on_tasks(tasks)
  rescue => e
  end

  def self.destroy_repo
    @repo.destroy_repo
  rescue => e
  end

end
