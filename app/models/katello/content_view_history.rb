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
class ContentViewHistory < Katello::Model

  belongs_to :environment, :class_name => "Katello::KTEnvironment", :inverse_of => :content_view_histories,
             :foreign_key => :katello_environment_id
  belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion", :foreign_key => :katello_content_view_version_id

  validates :environment, :presence => true
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :notes

  IN_PROGRESS = 'in progress'
  FAILED = 'failed'
  SUCCESSFUL = 'successful'
  STATUSES = [IN_PROGRESS, FAILED, SUCCESSFUL]

  validates :status, :inclusion => {:in          => STATUSES,
                                    :allow_blank => false}

  scope :active, where(:status => IN_PROGRESS)

end
end
