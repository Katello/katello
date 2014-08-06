#
# Copyright 2014 Red Hat, Inc.
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

  before_destroy :check_ready_to_destroy!

  belongs_to :content_view, :class_name => "Katello::ContentView", :inverse_of => :content_view_versions
  has_many :content_view_environments, :class_name => "Katello::ContentViewEnvironment",
           :dependent => :destroy
  has_many :environments, :through      => :content_view_environments,
                          :class_name   => "Katello::KTEnvironment",
                          :inverse_of   => :content_view_versions,
                          :after_remove => :remove_environment

  has_many :history, :class_name => "Katello::ContentViewHistory", :inverse_of => :content_view_version,
           :dependent => :destroy, :foreign_key => :katello_content_view_version_id
  has_many :repositories, :class_name => "Katello::Repository", :dependent => :destroy
  has_many :content_view_puppet_environments, :class_name => "Katello::ContentViewPuppetEnvironment",
           :dependent => :destroy
  has_one :task_status, :class_name => "Katello::TaskStatus", :as => :task_owner, :dependent => :destroy

  has_many :content_view_components, :inverse_of => :content_view_version, :dependent => :destroy
  has_many :composite_content_views, :through => :content_view_components, :source => :content_view

  delegate :default, :default?, to: :content_view

  scope :default_view, joins(:content_view).where("#{Katello::ContentView.table_name}.default" => true)
  scope :non_default_view, joins(:content_view).where("#{Katello::ContentView.table_name}.default" => false)

  def self.with_library_repo(repo)
    joins(:repositories).where("#{Katello::Repository.table_name}.library_instance_id" => repo)
  end

  def to_s
    name
  end

  def organization
    content_view.organization
  end

  def active_history
    self.history.select{|history| history.task.pending}
  end

  def last_event
    self.history.order(:created_at).last
  end

  def name
    "#{content_view} #{version}"
  end

  def has_default_content_view?
    default?
  end

  def available_releases
    self.repositories.pluck(:minor).compact.uniq.sort
  end

  def repos(env)
    self.repositories.in_environment(env)
  end

  def puppet_env(env)
    self.content_view_puppet_environments.in_environment(env).first
  end

  def puppet_modules
    self.content_view_puppet_environments.first.puppet_modules
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

  def removable?
    if environments.blank?
      content_view.promotable_or_removable?
    else
      content_view.promotable_or_removable? && KTEnvironment.where(:id => environments).any_promotable?
    end
  end

  def deletable?(from_env)
    !System.exists?(:environment_id => from_env, :content_view_id => self.content_view) ||
        self.content_view.versions.in_environment(from_env).count > 1
  end

  def archive_puppet_environment
    content_view_puppet_environments.archived.first
  end

  def puppet_modules
    if archive_puppet_environment
      archive_puppet_environment.indexed_puppet_modules
    else
      []
    end
  end

  def packages
    repositories.archived.flat_map(&:packages)
  end

  def package_count
    Package.package_count(self.repositories.archived)
  end

  def errata
    repositories.archived.flat_map(&:errata)
  end

  def errata_count(errata_type = nil)
    Errata.errata_count(self.repositories.archived, errata_type)
  end

  def errata_type_counts
    Errata::TYPES.each_with_object({}) do |type, counts|
      counts[type] = errata_count(type)
    end
  end

  def check_ready_to_promote!
    fail _("Default content view versions cannot be promoted") if default?
  end

  def check_ready_to_destroy!
    if environments.any? && !organization.being_deleted?
      fail _("Cannot delete version while it is in environments: %s") % environments.map(&:name).join(",")
    end
    return true
  end

  private

  def remove_environment(env)
    content_view.remove_environment(env) unless content_view.content_view_versions.in_environment(env).count > 1
  end

end
end
