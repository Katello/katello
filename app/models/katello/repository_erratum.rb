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
#

module Katello
class RepositoryErratum < Katello::Model
  self.include_root_in_json = false

  # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
  belongs_to :repository, :inverse_of => :repository_errata, :class_name => 'Katello::Repository'
  belongs_to :erratum, :inverse_of => :repository_errata, :class_name => 'Katello::Erratum'

end
end
