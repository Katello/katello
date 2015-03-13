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

    has_many :content_view_version_components, :inverse_of => :composite_version, :dependent => :destroy, :foreign_key => :composite_version_id,
             :class_name => "Katello::ContentViewVersionComponent"
    has_many :components, :through => :content_view_version_components, :source => :component_version,
             :class_name => "Katello::ContentViewVersion", :inverse_of => :composites

    has_many :content_view_version_composites, :inverse_of => :component_version, :dependent => :destroy, :foreign_key => :component_version_id,
             :class_name => "Katello::ContentViewVersionComponent"
    has_many :composites, :through => :content_view_version_composites, :source => :composite_version,
             :class_name => "Katello::ContentViewVersion", :inverse_of => :components

    delegate :default, :default?, to: :content_view

    validates_lengths_from_database

    scope :default_view, joins(:content_view).where("#{Katello::ContentView.table_name}.default" => true)
    scope :non_default_view, joins(:content_view).where("#{Katello::ContentView.table_name}.default" => false)

    def self.component_of(versions)
      joins(:content_view_version_composites).where("#{Katello::ContentViewVersionComponent.table_name}.composite_version_id" => versions)
    end

    def self.with_library_repo(repo)
      joins(:repositories).where("#{Katello::Repository.table_name}.library_instance_id" => repo)
    end

    def self.for_version(version)
      major, minor = version.to_s.split('.')
      query = where(:major => major)
      query.where(:minor => minor) if minor
      query
    end

    def to_s
      name
    end

    delegate :organization, to: :content_view

    def active_history
      self.history.select { |history| history.task.pending }
    end

    def last_event
      self.history.order(:created_at).last
    end

    def name
      "#{content_view} #{version}"
    end

    def default_content_view?
      default?
    end

    def available_releases
      self.repositories.pluck(:minor).compact.uniq.sort
    end

    def next_incremental_version
      "#{major}.#{minor + 1}"
    end

    def version
      "#{major}.#{minor}"
    end

    def repos(env)
      self.repositories.in_environment(env)
    end

    def puppet_env(env)
      self.content_view_puppet_environments.in_environment(env).first
    end

    def archived_repos
      self.default? ? self.repositories : self.repos(nil)
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

    def promotable?(environment)
      environments.include?(environment.prior) || environments.empty? && environment == organization.library
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

    def components_needing_errata(errata)
      component_repos = Repository.where(:content_view_version_id => self.components)
      library_repos = Repository.where(:id => component_repos.pluck(:library_instance_id)).with_errata(errata)
      component_repos -= component_repos.with_errata(errata) #find component repos without the errata
      component_repos.select { |repo| library_repos.include?(repo.library_instance) }.map(&:content_view_version).uniq
    end

    def packages
      archived_repos.flat_map(&:packages)
    end

    def puppet_module_count
      PuppetModule.module_count([self.archive_puppet_environment])
    end

    def package_count
      Package.package_count(self.repositories.archived)
    end

    def docker_image_count
      image_counts = repositories.archived.docker_type.map do |repo|
        repo.docker_images.count
      end
      image_counts.sum
    end

    def docker_tags
      archived_repos.docker_type.flat_map(&:docker_tags)
    end

    def docker_tag_count
      tag_counts = repositories.archived.docker_type.map do |repo|
        repo.docker_tags.count
      end
      tag_counts.sum
    end

    def errata(errata_type = nil)
      errata = Erratum.in_repositories(archived_repos).uniq
      errata = errata.of_type(errata_type) if errata_type
      errata
    end

    def docker_images
      DockerImage.in_repositories(archived_repos).uniq
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
