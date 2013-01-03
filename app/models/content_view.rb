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
    :presence => true, :katello_label_format => true
  validates :name, :presence => true, :katello_name_format => true
  validates :organization_id, :presence => true

  scope :default, where(:default=>true)
  scope :non_default, where(:default=>false)

  def publishing?
    # Is this view currently in the process of being published?
    task = publish_task_status
    return task.pending? unless task.nil?
    return false
  end

  def publish_error?
    # Did the current view fail during publishing?
    task = publish_task_status
    task.nil? ? true : task.error?
  end

  def publish_task_id
    # If the view is currently being published, return the id associated with the task
    task = publish_task_status
    return task.id if task && task.pending?
    return nil
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

  def environments
    KTEnvironment.joins(:content_view_versions).where('content_view_versions.content_view_id' => self.id)
  end

  def version(env)
    self.versions.in_environment(env).last
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
    #remove this when refresh is supported
    raise "Cannot promote to #{to_env.name}, view already exist there and refreshing not supported." if self.environments.include?(to_env)

    version = self.version(from_env)
    version.environments << to_env
    version.save!
    tasks = []
    self.repos(from_env).each do |repo|
      clone = repo.create_clone(to_env, self)
      tasks << repo.clone_contents(clone)
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

    # retrieve the version that is currently in the library
    library_version = self.version(self.organization.library)
    if library_version.environments.length == 1
      # the version initially in library was only associated with the library, so destroy it
      library_version.destroy
    else
      # the current version was associated with multiple environments, so only unassociate it from the library
      library_version.environments.delete(self.organization.library)
    end

    # create a new version
    version = ContentViewVersion.create!(:version => next_version_id, :content_view => self,
                                         :environments => [organization.library])

    if options[:async]
      task  = version.async(:organization => self.organization,
                            :task_type => TaskStatus::TYPES[:content_view_refresh][:type]).
                      refresh_version(options[:notify])

      version.task_status = task
      version.save!
    else
      version.task_status = nil
      version.save!
      version.refresh_version(options[:notify])
    end

    version
  end

  private

  def publish_task_status
    # If the view has a version available from when it was originally published, return it's task status.
    library_version = self.version(self.organization.library)
    if library_version && library_version.task_status &&
        library_version.task_status.task_type == TaskStatus::TYPES[:content_view_publish][:type].to_s

      return library_version.task_status
    else
      return nil
    end
  end

end
