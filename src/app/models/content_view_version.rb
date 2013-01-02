#
# Copyright 2011 Red Hat, Inc.
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
  has_many :environments, :through=>:content_view_version_environments,
           :class_name=>"KTEnvironment", :inverse_of=>:content_view_versions

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

  def self.in_environment(env)
    joins(:content_view_version_environments).where('content_view_version_environments.environment_id'=>env).
        order('content_view_version_environments.environment_id')
  end

  def refresh_version(notify = false)
    PulpTaskStatus::wait_for_tasks refresh_repos

    if notify
      message = _("Successfully refreshed content view '%{view_name}' to version %{view_version}.") %
          {:view_name => self.content_view.name, :view_version => self.version}

      Notify.success(message, :request_type => "content_view_definitions___refresh",
                     :organization => self.content_view.organization)
    end

  rescue => e
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))

    if notify
      message = _("Failed to refresh content view '%{view_name}' to version %{view_version}.") %
          {:view_name => self.content_view.name, :view_version => self.version}

      Notify.exception(message, e, :request_type => "content_view_definitions___refresh",
                       :organization => self.content_view.organization)
    end

    raise e
  end

  def refresh_repos
    repos = self.content_view.content_view_definition.nil? ? [] : self.content_view.content_view_definition.repos

    async_tasks = []
    repos.each do |repo|
      library_clone = repo.get_clone(self.content_view.organization.library)
      if library_clone.nil?
        # this repo doesn't currently exist in the library
        clone = repo.create_clone(self.content_view.organization.library, self.content_view)
        async_tasks << repo.clone_contents(clone)
      else
        # this repo already exists in the library, so update it
        library_clone = Repository.find(library_clone.id) # reload readonly obj
        library_clone.content_view_version = self
        library_clone.save!
        async_tasks << library_clone.sync
      end
    end
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

end
