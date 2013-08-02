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


module Katello
  class ContentViewVersion < ActiveRecord::Base
    include AsyncOrchestration
    include Authorization::ContentViewVersion

    belongs_to :content_view
    has_many :content_view_version_environments, :dependent => :destroy
    has_many :environments, {:through      => :content_view_version_environments,
                             :class_name   => "Katello::KTEnvironment",
                             :inverse_of   => :content_view_versions,
                             :before_add    => :add_environment,
                             :after_remove => :remove_environment
                            }

    has_many :repositories, :dependent => :destroy
    has_one :task_status, :as => :task_owner, :dependent => :destroy
    belongs_to :definition_archive, :class_name => Katello::ContentViewDefinitionArchive,
      :inverse_of => :content_view_versions

    validates :definition_archive_id, :presence => true, :if => :has_definition?

    before_validation :create_archived_definition

    scope :default_view, joins(:content_view).where("#{ContentView.table_name}.default" => true)
    scope :non_default_view, joins(:content_view).where("#{ContentView.table_name}.default" => false)

    def has_default_content_view?
      ContentViewVersion.default_view.pluck("#{ContentViewVersion.table_name}.id").include?(self.id)
    end

    def repos(env)
      self.repositories.in_environment(env)
    end

    def products(env=nil)
      if env
        repos(env).map(&:product).uniq(&:id)
      else
        self.repositories.map(&:product).uniq(&:id)
      end
    end

    def content_view_definition
      @definition ||= content_view.definition
    end

    def has_definition?
      content_view_definition.present?
    end

    def repos_ordered_by_product(env)
      # The repository model has a default scope that orders repositories by name;
      # however, for content views, it is desirable to order the repositories
      # based on the name of the product the repository is part of.
      Repository.send(:with_exclusive_scope) do
        self.repositories.joins(:product).in_environment(env).order("#{Product.table_name}.name asc")
      end
    end

    def get_repo_clone(env, repo)
      lib_id = repo.library_instance_id || repo.id
      self.repos(env).where("#{Repository.table_name}.library_instance_id" => lib_id)
    end

    def self.in_environment(env)
      joins(:content_view_version_environments).where('katello_content_view_version_environments.environment_id'=>env).
          order('katello_content_view_version_environments.environment_id')
    end

    def refresh_version(notify = false)
      PulpTaskStatus::wait_for_tasks self.refresh_repos
      PulpTaskStatus::wait_for_tasks self.generate_metadata
      self.content_view.index_repositories(self.content_view.organization.library)
      self.content_view.update_cp_content(self.content_view.organization.library) if Katello.config.use_cp

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

    def refresh_repos
      # generate a hash of the repos associated with the definition, where key = repo id & value = repo
      definition_repos_hash = has_definition? ?
          Hash[ self.content_view.content_view_definition.repos.collect{|repo| [repo.id, repo]}] : {}

      async_tasks = []
      # prepare the repos currently in the library for the refresh
      self.repositories.in_environment(self.content_view.organization.library).each do |repo|
        if definition_repos_hash.include?(repo.library_instance_id)
          # this repo is in both the definition and in the previous library version,
          # so clear it and later we'll regenerate the content... this is more
          # efficient than deleting the repo and recreating it...
          async_tasks +=  repo.clear_contents
        else
          # this repo no longer exists in the definition, so destroy it
          repo.destroy
        end
        self.reload
      end
      PulpTaskStatus::wait_for_tasks async_tasks unless async_tasks.blank?

      async_tasks = []
      repos_to_filter = []
      definition_repos_hash.each do |repo_id, repo|
        # the repos from the definition are based upon initial synced repos, we need to
        # determine if each of those repos has been cloned in the view...
        library_clone = self.content_view.get_repo_clone(self.content_view.organization.library, repo).first
        if library_clone.nil?
          # this repo doesn't currently exist in the library
          clone = repo.create_clone(self.content_view.organization.library, self.content_view)
          async_tasks << repo.clone_contents(clone)
          repos_to_filter << clone
        else
          # this repo already exists in the library, so update it
          library_clone = Repository.find(library_clone) # reload readonly obj
          async_tasks << repo.clone_contents(library_clone)
          repos_to_filter << library_clone
        end
      end
      if has_definition?
        self.content_view.content_view_definition.unassociate_contents(repos_to_filter)
      end

      async_tasks.flatten(1)
    end

    def deletable?(from_env)
      !System.exists?(:environment_id=>from_env, :content_view_id=>self.content_view) ||
          self.content_view.versions.in_environment(from_env).count > 1
    end

    def delete(from_env)
      unless deletable?(from_env)
            raise Errors::ChangesetContentException.new(_("Cannot delete view %{view} from %{env}, systems are currently subscribed. " +
                                                        "Please move subscribed systems to another content view or environment.") %
                                                            {:env=>from_env.name, :view=>self.content_view.name})
      end

      self.environments.delete(from_env)
      self.repositories.in_environment(from_env).each{|r| r.destroy}
      if self.environments.empty?
        self.destroy
      else
        self.save!
      end
    end

    def generate_metadata
      self.repositories.collect{|repo| repo.generate_metadata}.flatten(1)
    end

    private

    def add_environment(env)
      content_view.add_environment(env) if content_view.content_view_versions.in_environment(env).count == 0
    end

    def remove_environment(env)
      content_view.remove_environment(env)  unless content_view.content_view_versions.in_environment(env).count > 1
    end

    def create_archived_definition
      if has_definition? && self.definition_archive.nil?
        self.definition_archive = content_view_definition.archive
      end
    end

  end
end
