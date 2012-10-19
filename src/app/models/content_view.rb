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
  has_many :environment_defaults, :class_name => "KTEnvironment",
    :inverse_of => :default_content_view,
    :foreign_key => :default_content_view_id

  has_many :environment_content_views
  has_many :environments, :through => :environment_content_views,
    :class_name => "KTEnvironment"

  has_many :content_view_components, :foreign_key => :composite_id
  has_many :component_content_views, :through => :content_view_components,
    :source => :component

  has_many :content_view_composites, :class_name => "ContentViewComponent",
    :inverse_of => :component, :foreign_key => :component_id
  has_many :composite_content_views, :through => :content_view_composites,
    :source => :composite

  validates :label, :uniqueness => {:scope => :organization_id},
    :presence => true, :katello_label_format => true
  validates :name, :presence => true, :katello_name_format => true
  validates :organization_id, :presence => true

  def as_json(options = {})
    result = self.attributes
    result['organization'] = self.organization.try(:name)

    environments = (self.environments + [organization.library]).compact
    result['environments'] = environments.map{|e| e.try(:name)}.join(", ")
    result['published'] = true

    result
  end
end
