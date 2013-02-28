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


class ContentViewVersion < ActiveRecord::Base
  include AsyncOrchestration

  belongs_to :content_view
  has_many :content_view_version_environments
  has_many :environments, {:through      => :content_view_version_environments,
                           :class_name   => "KTEnvironment",
                           :inverse_of   => :content_view_versions,
                           :after_add    => :add_environment,
                           :after_remove => :remove_environment
                          }

  has_many :repositories, :dependent => :destroy

  has_one :task_status, :as => :task_owner, :dependent => :destroy

  scope :default_view, joins(:content_view).where('content_views.default = ?', true)
  scope :non_default_view, joins(:content_view).where('content_views.default = ?', false)

  def has_default_content_view?
    ContentViewVersion.default_view.pluck(:id).include?(self.id)
  end

  def repos(env)
    self.repositories.in_environment(env)
  end

  def repos_ordered_by_product(env)
    # The repository model has a default scope that orders repositories by name;
    # however, for content views, it is desirable to order the repositories
    # based on the name of the product the repository is part of.
    Repository.send(:with_exclusive_scope) {self.repositories.joins(:environment_product => :product).
        in_environment(env).order('products.name asc')}
  end

  def get_repo_clone(env, repo)
    lib_id = repo.library_instance_id || repo.id
    self.repos(env).where('repositories.library_instance_id' => lib_id)
  end

  def self.in_environment(env)
    joins(:content_view_version_environments).where('content_view_version_environments.environment_id'=>env).
        order('content_view_version_environments.environment_id')
  end

  def refresh_version(library_version, notify = false)
    PulpTaskStatus::wait_for_tasks refresh_repos(library_version)

    if notify
      message = _("Successfully generated content view '%{view_name}' version %{view_version}.") %
          {:view_name => self.content_view.name, :view_version => self.version}

      Notify.success(message, :request_type => "content_view_definitions___refresh",
                     :organization => self.content_view.organization)
    end

  rescue => e
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))

    if notify
      message = _("Failed to generate content view '%{view_name}' version %{view_version}.") %
          {:view_name => self.content_view.name, :view_version => self.version}

      Notify.exception(message, e, :request_type => "content_view_definitions___refresh",
                       :organization => self.content_view.organization)
    end

    raise e
  end

  def refresh_repos(library_version)
    # generate a hash of the repos associated with the definition, where key = repo id & value = repo
    definition_repos_hash = self.content_view.content_view_definition.nil? ? {} :
        Hash[ self.content_view.content_view_definition.repos.collect{|repo| [repo.id, repo]}]

    async_tasks = []
    # prepare the repos currently in the library for the refresh
    library_version.repositories.in_environment(self.content_view.organization.library).each do |repo|
      if definition_repos_hash.include?(repo.library_instance_id)
        # this repo is in both the definition and in the previous library version,
        # so clear it and later we'll regenerate the content... this is more
        # efficient than deleting the repo and recreating it...
        async_tasks << repo.clear_contents
      else
        # this repo no longer exists in the definition, so destroy it
        repo.destroy
      end
      library_version.reload
    end
    PulpTaskStatus::wait_for_tasks async_tasks unless async_tasks.blank?

    async_tasks = []
    definition_repos_hash.each do |repo_id, repo|
      # the repos from the definition are based upon initial synced repos, we need to
      # determine if each of those repos has been cloned in the view...
      library_clone = library_version.get_repo_clone(self.content_view.organization.library, repo).first
      if library_clone.nil?
        # this repo doesn't currently exist in the library
        clone = repo.create_clone(self.content_view.organization.library, self.content_view)
        async_tasks << repo.clone_contents(clone)
      else
        # this repo already exists in the library, so update it
        library_clone = Repository.find(library_clone) # reload readonly obj
        library_clone.content_view_version = self
        library_clone.save!
        async_tasks << repo.clone_contents(library_clone)
      end
    end
    library_version.destroy if library_version.environments.length == 0
    async_tasks.flatten(1)
  end

  def delete(from_env)
    self.environments.delete(from_env)
    self.repositories.in_environment(from_env).each{|r| r.destroy}
    if self.environments.empty?
      self.destroy
    else
      self.save!
    end
  end

  private

  def add_environment(env)
    content_view.add_environment(env)
  end

  def remove_environment(env)
    content_view.remove_environment(env)
  end

end
