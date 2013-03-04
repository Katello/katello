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

class Filter < ActiveRecord::Base
  belongs_to :content_view_definition
  has_many  :rules, :class_name => "FilterRule", :dependent => :destroy
  has_and_belongs_to_many :repositories, :class_name => "Repository", :uniq => true
  
  validates :name, :presence => true, :allow_blank => false,
              :length => { :maximum => 255 }, 
              :uniqueness => {:scope => :content_view_definition_id}

  def self.applicable(repo)
    joins("inner join filters_repositories on filters_repositories.filter_id = filters.id").where("filters_repositories.repository_id = ?", repo.id)
  end

  def as_json(options = {})
    options ||= {}
    ret = super(options)
    ret["content_view_definition_label"] = content_view_definition.label
    ret["organization"] = content_view_definition.organization.label
    ret
  end
end
