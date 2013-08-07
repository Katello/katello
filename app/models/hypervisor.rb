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

class Hypervisor < System
  use_index_of System if Katello.config.use_elasticsearch

  UNSUPPORTED_ACTIONS = [:package_profile, :pulp_facts, :simple_packages, :errata, :del_pulp_consumer, :set_pulp_consumer,
                         :update_pulp_consumer, :upload_package_profile, :install_package, :uninstall_package,
                         :update_package, :install_package_group, :uninstall_package_group]

  UNSUPPORTED_ACTIONS.each do |unsupported_action|
    define_method(unsupported_action) do
      raise Errors::UnsupportedActionException.new(unsupported_action, self, _("Hypervisor does not support this action"))
    end
  end
end
