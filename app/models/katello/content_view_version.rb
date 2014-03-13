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
class ContentViewVersion < Katello::Model
  self.include_root_in_json = false

  include AsyncOrchestration
  include Authorization::ContentViewVersion

  belongs_to :content_view, :class_name => "Katello::ContentView", :inverse_of => :content_view_versions
  has_many :content_view_environments, :class_name => "Katello::ContentViewEnvironment",
           :dependent => :nullify
  has_many :environments, :through      => :content_view_environments,
                          :class_name   => "Katello::KTEnvironment",
                          :inverse_of   => :content_view_versions,
                          :after_remove => :remove_environment do
                            def <<(env)
                              proxy_association.owner.add_environment(env)
                            end
                          end

  has_many :history, :class_name => "Katello::ContentViewHistory", :inverse_of => :content_view_version,
           :dependent => :destroy, :foreign_key => :katello_content_view_version_id
  has_many :repositories, :class_name => "Katello::Repository", :dependent => :destroy
  has_many :content_view_puppet_environments, :class_name => "Katello::ContentViewPuppetEnvironment",
           :dependent => :destroy
  has_one :task_status, :class_name => "Katello::TaskStatus", :as => :task_owner, :dependent => :destroy

  has_many :content_view_components, :inverse_of => :content_view_version
  has_many :composite_content_views, :through => :content_view_components, :source => :content_view

  scope :default_view, joins(:content_view).where("#{Katello::ContentView.table_name}.default" => true)
  scope :non_default_view, joins(:content_view).where("#{Katello::ContentView.table_name}.default" => false)

  def self.with_library_repo(repo)
    joins(:repositories).where("#{Katello::Repository.table_name}.library_instance_id" => repo)
  end

  def self.with_puppet_module(name)
    joins(:content_view_puppet_environments).
      where("#{ContentViewPuppetEnvironment.table_name}.name = ?", name)
  end

  def to_s
    name
  end

  def active_history
    self.history.active
  end

  def name
    "#{content_view} #{version}"
  end

  def has_default_content_view?
    ContentViewVersion.default_view.pluck("#{Katello::ContentViewVersion.table_name}.id").include?(self.id)
  end

  def repos(env)
    self.repositories.in_environment(env)
  end

  def puppet_env(env)
    self.content_view_puppet_environments.in_environment(env).first
  end

  def archived_repos
    self.repos(nil)
  end

  def non_archive_repos
    self.repositories.non_archived
  end

  def products(env = nil)
    if env
      repos(env).map(&:product).uniq(&:id)
    else
      self.repositories.map(&:product).uniq(&:id)
    end
  end

  def repos_ordered_by_product(env)
    # The repository model has a default scope that orders repositories by name;
    # however, for content views, it is desirable to order the repositories
    # based on the name of the product the repository is part of.
    Repository.send(:with_exclusive_scope) do
      self.repositories.joins(:product).in_environment(env).order("#{Katello::Product.table_name}.name asc")
    end
  end

  def get_repo_clone(env, repo)
    lib_id = repo.library_instance_id || repo.id
    self.repos(env).where("#{Katello::Repository.table_name}.library_instance_id" => lib_id)
  end

  def self.in_environment(env)
    joins(:content_view_environments).where("#{Katello::ContentViewEnvironment.table_name}.environment_id" => env)
      .order("#{Katello::ContentViewEnvironment.table_name}.environment_id")
  end

  def deletable?(from_env)
    !System.exists?(:environment_id => from_env, :content_view_id => self.content_view) ||
        self.content_view.versions.in_environment(from_env).count > 1
  end

  def promote(to_env, options = {:async => true})
    history = ContentViewHistory.create!(:content_view_version => self, :user => User.current.login,
                               :environment => to_env, :status => ContentViewHistory::IN_PROGRESS)

    replacing_version = self.content_view.version(to_env)

    promote_version = ContentViewVersion.find(self.id)
    promote_version.environments << to_env unless promote_version.environments.include?(to_env)
    promote_version.save!

    replacing_version.environments.delete(to_env) if replacing_version

    if options[:async]
      self.async(:organization => self.content_view.organization).promote_content(to_env, replacing_version,
                                                                                  history)
    else
      promote_content(to_env, replacing_version, history)
    end
  end

  def promote_content(to_env, replacing_version, history)
    puppet_env = self.puppet_env(to_env.prior)  # puppet env to be promoted

    if replacing_version
      PulpTaskStatus.wait_for_tasks(prepare_repos_for_promotion(replacing_version.repos(to_env), self.archived_repos))
      prepare_puppet_env_for_promotion(replacing_version.puppet_env(to_env), puppet_env)
    end

    PulpTaskStatus.wait_for_tasks(promote_repos(to_env, self.archived_repos))
    promote_puppet_env(to_env, puppet_env) if puppet_env

    Katello::Foreman.update_foreman_content(to_env.organization, to_env, self.content_view)
    self.content_view.update_cp_content(to_env)

    Repository.trigger_contents_changed(self.repos(to_env), :wait => true, :reindex => true)
    history.update_attributes!(:status => ContentViewHistory::SUCCESSFUL)

  rescue => e
    history.update_attributes!(:status => ContentViewHistory::FAILED)
    raise e
  end

  def prepare_repos_for_promotion(repos_to_replace, repos_to_promote)
    tasks = repos_to_replace.inject([]) do |result, repo|
      if repos_to_promote.detect{|r| r.library_instance_id == repo.library_instance_id}
        # a version of this repo is being promoted, so clear it and later
        # we'll regenerate the content... this is more efficient than
        # destroying the repo and recreating it...
        result += repo.clear_contents
      else
        # a version of this repo is not being promoted, so destroy it
        repo.destroy
        result
      end
    end
    tasks
  end

  def promote_repos(to_env, promoting_repos)
    # promote the repos to the target env
    tasks = []
    promoting_repos.each do |repo|
      clone = self.get_repo_clone(to_env, repo).first
      if clone.nil?
        # this repo doesn't currently exist in the next environment, so create it
        clone = repo.create_clone({:environment => to_env, :content_view => self.content_view})
        tasks << repo.clone_contents(clone)
      else
        # this repo already exists in the next environment, so update it
        clone = Repository.find(clone) # reload readonly obj
        clone.content_view_version = self
        clone.save!
        tasks << repo.clone_contents(clone)
      end
    end

    tasks.flatten
  end

  def prepare_puppet_env_for_promotion(env_to_replace, env_to_promote)
    # If the to_env already has a puppet environment from a previous promotion,
    # clear it if the from_env also has a puppet environment that is being promoted;
    # otherwise, delete it.
    if env_to_replace
      if env_to_promote
        PulpTaskStatus.wait_for_tasks(env_to_replace.clear_contents)
      else
        env_to_replace.destroy
      end
    end
  end

  def promote_puppet_env(to_lifecycle_env, from_puppet_env)
    to_puppet_env = Katello::ContentViewPuppetEnvironment.in_content_view(self.content_view).
        in_environment(to_lifecycle_env).first

    if to_puppet_env
      to_puppet_env = ContentViewPuppetEnvironment.find(to_puppet_env) # reload readonly obj
      to_puppet_env.content_view_version = self
      to_puppet_env.save!
    else
      to_puppet_env = content_view.create_puppet_env(:environment => to_lifecycle_env, :content_view => self.content_view)
    end

    PulpTaskStatus.wait_for_tasks(from_puppet_env.clone_contents(to_puppet_env))
    ContentViewPuppetEnvironment.trigger_contents_changed([to_puppet_env], :wait => true, :reindex => true)
  end

  def delete(from_env)
    unless deletable?(from_env)
      fail Errors::ChangesetContentException.new(_("Cannot delete view %{view} from %{env}, systems are currently subscribed. " +
                                                    "Please move subscribed systems to another content view or environment.") %
                                                    {:env => from_env.name, :view => self.content_view.name})
    end

    self.environments.delete(from_env)
    self.repositories.in_environment(from_env).each{|r| r.destroy}
    if self.environments.empty?
      self.destroy
    else
      self.save!
    end
  end

  def trigger_contents_changed(options = {})
    repos_changed = options[:non_archive] ? non_archive_repos : repositories.reload

    Repository.trigger_contents_changed(repos_changed, :wait => true, :reindex => true,
                                        :cloned_repo_overrides => options.fetch(:cloned_repo_overrides, []))

    envs_changed = if options[:non_archive]
                     content_view_puppet_environments.non_archived
                   else
                     content_view_puppet_environments.reload
                   end

    ContentViewPuppetEnvironment.trigger_contents_changed(envs_changed, :wait => true, :reindex => true)
  end

  def environments=(envs)
    envs.each do |environment|
      add_environment(environment)
    end
  end

  def add_environment(env)
    if content_view.environments.include?(env)
      # use the existing content_view_environment
      cve = ContentViewEnvironment.find_by_environment_id_and_content_view_id(env, content_view_id)
      self.content_view_environments << cve
    else
      env = content_view.add_environment(env, self)
      ForemanTasks.sync_task(::Actions::Headpin::ContentView::EnvironmentCreate, env)
    end
  end

  def archive_puppet_environment
    content_view_puppet_environments.archived.first
  end

  def puppet_modules
    archive_puppet_environment.puppet_modules
  end

  private

  def remove_environment(env)
    content_view.remove_environment(env) unless content_view.content_view_versions.in_environment(env).count > 1
  end

end
end
