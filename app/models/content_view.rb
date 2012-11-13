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

  belongs_to :content_view_definition
  belongs_to :organization
  has_one :environment_default, :class_name => "KTEnvironment",
    :inverse_of => :default_content_view,
    :foreign_key => :default_content_view_id

  has_many :environment_content_views
  has_many :environments, :through => :environment_content_views,
    :class_name => "KTEnvironment", :inverse_of=>:content_views


  has_many :component_content_views
  has_many :composite_content_view_definitions,
    :through => :component_content_views, :source => "content_view_definition"

  has_many :repositories, :dependent => :destroy

  has_many :changeset_content_views
  has_many :changesets, :through => :changeset_content_views

  validates :label, :uniqueness => {:scope => :organization_id},
    :presence => true, :katello_label_format => true
  validates :name, :presence => true, :katello_name_format => true
  validates :organization_id, :presence => true

  scope :default, joins('left outer join environments on content_views.id = environments.default_content_view_id').
      where('environments.default_content_view_id is not null')
  scope :non_default, joins('left outer join environments on content_views.id = environments.default_content_view_id').
        where('environments.default_content_view_id is null')


  def as_json(options = {})
    result = self.attributes
    result['organization'] = self.organization.try(:name)

    environments = (self.environments + [organization.library]).compact
    result['environments'] = environments.map{|e| e.try(:name)}.join(", ")
    result['published'] = true

    result
  end

  #is this content view a default
  def default?
    !self.environment_default.nil?
  end

  def promote(from_env, to_env)
    raise "Cannot promote from #{from_env.name}, view does not exist there." if !self.environments.include?(from_env)
    #remove this when refresh is supported
    raise "Cannot promote to #{to_env.name}, view already exist there and refreshing not supported." if self.environments.include?(to_env)

    self.environments << to_env
    self.save!
    tasks = []
    self.repositories.each do |repo|
      clone = repo.create_clone(to_env, self)
      tasks << repo.clone_contents(clone)
    end
    tasks
  end

  def delete(from_env)
    raise "Cannot delete from #{from_env.name}, view does not exist there." if !self.environments.include?(from_env)
    self.environments.delete(from_env)
    self.repositories.in_environment(from_env).each{|r| r.destroy}
    if self.environments.empty?
      self.destroy
    else
      self.save!
    end
  end

end
