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

class Filter < ActiveRecord::Base
  belongs_to :content_view_definition
  has_many  :rules, :class_name => "FilterRule", :dependent => :destroy
  has_and_belongs_to_many :repositories, :class_name => "Repository", :uniq => true

  validates :name, :presence => true, :allow_blank => false,
              :length => { :maximum => 255 },
              :uniqueness => {:scope => :content_view_definition_id}

  def self.applicable(repo)
    joins(:repositories).where(:repositories => {:id => repo.id})
  end

  def as_json(options = {})
    super(options).update("content_view_definition_label" => content_view_definition.label,
                          "organization" => content_view_definition.organization.label)
  end
end
