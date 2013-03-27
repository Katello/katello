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


class ContentViewDefinitionBase < ActiveRecord::Base
  belongs_to :organization, :inverse_of => :content_view_definitions
  has_many :content_view_definition_products, :foreign_key => "content_view_definition_id"
  has_many :products, :through => :content_view_definition_products
  has_many :content_view_definition_repositories, :foreign_key => "content_view_definition_id"
  has_many :repositories, :through => :content_view_definition_repositories
  has_many :components, :class_name => "ComponentContentView",
    :foreign_key => "content_view_definition_id"
  has_many :component_content_views, :through => :components,
    :source => :content_view, :class_name => "ContentView"

  validates :organization, :presence => true

  def archive?
    type =~ /Archive/
  end
end
