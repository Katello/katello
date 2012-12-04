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
  belongs_to :organization

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

  validates :label, :uniqueness => {:scope => :organization_id},
    :presence => true, :katello_label_format => true
  validates :name, :presence => true, :katello_name_format => true
  validates :organization_id, :presence => true

  scope :default, where(:default=>true)
  scope :non_default, where(:default=>false)

  def as_json(options = {})
    result = self.attributes
    result['organization'] = self.organization.try(:name)
    result['definition']   = self.content_view_definition.try(:name)
    result['environments'] = environments.map{|e| e.try(:name)}.join(", ")
    result['versions'] = versions.map(&:version)

    result
  end

  def environments
    KTEnvironment.joins(:content_view_versions).where('content_view_versions.content_view_id' => self.id)
  end

  def version(env)
    self.versions.in_environment(env).first
  end

  def repos(env)
    version = version(env)
    if version
      version.repositories.in_environment(env)
    else
      []
    end
  end

  def promote_via_changeset(env, apply_options = {:async => true},
                            cs_name = "#{self.name}_#{env.name}_#{Time.now.to_i}")
    cs = PromotionChangeset.create!(:name => cs_name,
                                     :environment => @environment,
                                     :state => Changeset::REVIEW,
                                     :content_views => [@view]
                                    )
    return cs.apply(apply_options)
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
    version = self.version(from_env)
    raise "Cannot delete from #{from_env.name}, view does not exist there." if version.nil?
    version.delete(from_env)
    self.destroy if self.versions.empty?
  end

end
