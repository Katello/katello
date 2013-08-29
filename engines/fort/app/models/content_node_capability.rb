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

class ContentNodeCapability < NodeCapability

  TYPE = 'content'

  after_save :enable_pulp_node

  def validate_configuration
    raise _("Oauth credentials cannot be blank") if self.configuration['oauth'].blank?
  end

  def enable_pulp_node
    self.node.system.activate_pulp_node
    true
  end

  def disable_pulp_node
    self.node.system.deactivate_pulp_node
    true
  end

  def update_environments
    self.node.system.enable_node_repos(calculate_bound_repos(self.node.environments))
  end

  def sync(options = {})
    env = options[:environment]
    view = options[:content_view]
    repo = options[:repository]

    relevant_repo_ids = repo_ids(repo, view, env)
    task = PulpSyncStatus.using_pulp_task(self.node.system.sync_pulp_node(relevant_repo_ids))
    task.save!
    task
  end

  private

  def repo_ids(repository = nil, view = nil, environment = nil)
    if repository
      [repository.pulp_id]
    elsif environment.nil? && view.nil?
      nil
    else
      repos = Repository.enabled.in_environment(self.node.environment_ids)
      repos = repos.in_environment(environment.id) if environment
      repos = repos.in_content_views([view]) if view
      repos.pluck(:pulp_id)
    end
  end

  def calculate_bound_repos(env_list)
    env_list.collect{|env| Repository.in_environment(env).enabled.pluck(:pulp_id)}.flatten
  end


end
