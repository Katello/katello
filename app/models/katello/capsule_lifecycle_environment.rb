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
  class CapsuleLifecycleEnvironment < Katello::Model
    validates_lengths_from_database
    validates :lifecycle_environment_id,
              :uniqueness => { :scope => :capsule_id,
                               :message => _("is already attached to the capsule") }

    belongs_to :capsule, :class_name => "::SmartProxy", :inverse_of => :capsule_lifecycle_environments
    belongs_to :lifecycle_environment, :class_name => "Katello::KTEnvironment", :inverse_of => :capsule_lifecycle_environments
  end
end
