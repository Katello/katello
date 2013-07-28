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

module Katello
  module ProxyAssociationOwner
    def proxy_association_owner
      /(\d+)\.(\d+)\.(\d+)/ =~ Rails.version
      (($1.to_i >= 4 ) or ($1.to_i == 3 and $2.to_i >= 1)) ? proxy_association.owner : proxy_owner
    end
  end
end
