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
class SystemHostCollection < Katello::Model
  self.include_root_in_json = false

  belongs_to :system, :inverse_of => :system_host_collections
  belongs_to :host_collection, :inverse_of => :system_host_collections

  validate :validate_max_content_hosts_not_exceeded

  def validate_max_content_hosts_not_exceeded
    if new_record?
      host_collection = HostCollection.find(self.host_collection_id)
      if (host_collection) && (host_collection.max_content_hosts != HostCollection::UNLIMITED_SYSTEMS) && (host_collection.systems.size >= host_collection.max_content_hosts)
        errors.add :base,
                   _("You cannot have more than %{max_content_hosts} content host(s) associated with host collection '%{host_collection}'.") %
                       { :max_content_hosts => host_collection.max_content_hosts, :host_collection => host_collection.name }
      end
    end
  end

end
end
