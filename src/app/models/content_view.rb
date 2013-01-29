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

require 'util/model_util.rb'

class ContentView < ActiveRecord::Base
  include Katello::LabelFromName
  include Authorization::ContentView

  belongs_to :content_view_definition
  belongs_to :organization, :inverse_of => :content_views

  has_many :content_view_versions, :dependent => :destroy
  alias :versions :content_view_versions

  has_one :environment_default, :class_name => "KTEnvironment",
      :inverse_of => :default_content_view,
      :foreign_key => :default_content_view_id

  has_many :component_content_views
  has_many :composite_content_view_definitions,
    :through => :component_content_views, :source => "content_view_definition"

  has_many :changeset_content_views
  has_many :changesets, :through => :changeset_content_views
  has_many :activation_keys




  validates :label, :uniqueness => {:scope => :organization_id},
    :presence => true
  validates :name, :presence => true
  validates :organization_id, :presence => true

  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label

  scope :default, where(:default=>true)
  scope :non_default, where(:default=>false)

  def self.in_environment(env)
    joins(:content_view_versions => :content_view_version_environments).
      where("content_view_version_environments.environment_id = ?", env.id)
  end

  def self.promoted(safe = false)
    # retrieve the view, if it has been promoted (i.e. exists in more than 1 environment)
    relation = self.joins(:content_view_versions => :environments).group('"content_views"."id"').
        having('count("environments"."id") > 1')

    if safe
      # do not include group and having in returned relation
      self.where :id => relation.all.map(&:id)
    else
      relation
    end
  end

  def to_s
    name
  end

  def promoted?
    # if the view exists in more than 1 environment, it has been promoted
    self.environments.length > 1 ? true : false
  end

  def as_json(options = {})
    result = self.attributes
    result['organization'] = self.organization.try(:name)
    result['definition']   = self.content_view_definition.try(:name)
    result['environments'] = environments.map{|e| e.try(:name)}.join(", ")
    result['versions'] = versions.map(&:version)
    result['versions_details'] = versions.map do |v|
      {
        :version => v.version,
        :published => v.created_at.to_s,
        :environments => v.environments.map{|e| e.name}
      }
    end

    if options && options[:environment].present?
      result['repositories'] = repos(options[:environment]).map(&:name)
    end

    result
  end

  def to_s
    name
  end

  def environments
    KTEnvironment.joins(:content_view_versions).where('content_view_versions.content_view_id' => self.id)
  end

  def version(env)
    self.versions.in_environment(env).order('content_view_versions.id ASC').last
  end

  def repos(env)
    version = version(env)
    if version
      version.repositories.in_environment(env)
    else
      []
    end
  end

  def repos_in_product(env, product)
    version = version(env)
    if version
      version.repositories.in_environment(env).in_product(product)
    else
      []
    end
  end

  def get_repo_clone(env, repo)
    lib_id = repo.library_instance_id || repo.id
    Repository.in_environment(env).where(:library_instance_id => lib_id).
        joins(:content_view_version => :content_view).where('content_views.id' => repo.content_view.id)
  end

  def promote_via_changeset(env, apply_options = {:async => true},
                            cs_name = "#{self.name}_#{env.name}_#{Time.now.to_i}")
    ActiveRecord::Base.transaction do
      cs = PromotionChangeset.create!(:name => cs_name,
                                      :environment => env,
                                      :state => Changeset::REVIEW
                                     )
      cs.add_content_view!(self)
      return cs.apply(apply_options)
    end
  end

  def promote(from_env, to_env)
    raise "Cannot promote from #{from_env.name}, view does not exist there." if !self.environments.include?(from_env)

    replacing_version = self.version(to_env)

    promote_version = self.version(from_env)
    promote_version.environments << to_env
    promote_version.save!

    # prepare the to_env for the promotion
    tasks = []
    if replacing_version
      replacing_version.repos(to_env).each do |repo|
        clone = self.get_repo_clone(from_env, repo).first
        if clone.nil?
          # this repo doesn't exist in the from environment, so destroy it
          repo.destroy
        else
          # this repo does exist in the next environment, so clear it and later
          # we'll regenerate the content... this is more efficient than deleting
          # the repo and recreating it...
          tasks << repo.clear_contents
        end
      end
    end
    PulpTaskStatus::wait_for_tasks tasks unless tasks.blank?

    # promote the repos from from_env to to_env
    tasks = []
    promote_version.repos(from_env).each do |repo|
      clone = self.get_repo_clone(to_env, repo).first
      if clone.nil?
        # this repo doesn't currently exist in the next environment, so create it
        clone = repo.create_clone(to_env, self)
        tasks << repo.clone_contents(clone)
      else
        # this repo already exists in the next environment, so update it
        clone = Repository.find(clone) # reload readonly obj
        clone.content_view_version = promote_version
        clone.save!
        tasks << repo.clone_contents(clone)
      end
    end

    if replacing_version
      if replacing_version.environments.length == 1
        replacing_version.destroy
      else
        replacing_version.environments.delete(to_env)
        replacing_version.save!
      end
    end

    tasks
  end

  def delete(from_env)
    if from_env.library? && in_non_library_environment?
      raise Exception, _("Cannot delete view while it exits in environments")
    end
    version = self.version(from_env)
    if version.nil?
      raise Exception, _("Cannot delete from %s, view does not exist there.") % from_env.name
    end
    version.delete(from_env)
    self.destroy if self.versions.empty?
  end

  def in_non_library_environment?
    environments.where(:library => false).length > 0
  end

  # Refresh the content view, creating a new version in the library.  The new version will be returned.
  def refresh_view(options = { })
    options = { :async => true, :notify => false }.merge options

    # retrieve the 'next' version id to use
    next_version_id = self.versions.maximum(:version) + 1

    # retrieve the version that is currently in the library and remove the library association.
    # at this point, we don't want to delete the version as we need to reference the repos it
    # contains during the refresh
    library_version = self.version(self.organization.library)
    library_version.environments.delete(self.organization.library)

    # create a new version
    version = ContentViewVersion.create!(:version => next_version_id, :content_view => self,
                                         :environments => [organization.library])

    if options[:async]
      task  = version.async(:organization => self.organization,
                            :task_type => TaskStatus::TYPES[:content_view_refresh][:type]).
                      refresh_version(library_version, options[:notify])

      version.task_status = task
      version.save!
    else
      version.task_status = nil
      version.save!
      version.refresh_version(library_version, options[:notify])
    end

    version
  end

end
