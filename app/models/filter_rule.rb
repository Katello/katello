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

class FilterRule < ActiveRecord::Base
  belongs_to :filter

  serialize :parameters, HashWithIndifferentAccess

  PACKAGE       = Runcible::Extensions::Rpm.content_type()
  PACKAGE_GROUP       = Runcible::Extensions::PackageGroup.content_type()
  ERRATA   = Runcible::Extensions::Errata.content_type()
  CONTENT_TYPES  = [PACKAGE, PACKAGE_GROUP, ERRATA]

  validates_inclusion_of :content_type,
                         :in          => CONTENT_TYPES,
                         :allow_blank => false,
                         :message     => "A filter rule must have one of the following types: #{CONTENT_TYPES.join(', ')}."
  def parameters
    write_attribute(:parameters, HashWithIndifferentAccess.new) unless read_attribute(:parameters)
    read_attribute(:parameters)
  end
end
