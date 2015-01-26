# encoding: utf-8
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

module Support
  class HostSupport
    def self.setup_host_for_view(host, view, environment, assign_to_puppet)
      puppet_env = ::Environment.create!(:name => 'blahblah')

      cvpe = view.version(environment).puppet_env(environment)
      cvpe.puppet_environment = puppet_env
      cvpe.save!

      host.update_column(:content_view_id, view.id)
      host.update_column(:lifecycle_environment_id, environment.id)
      host.update_column(:environment_id, cvpe.puppet_environment.id) if assign_to_puppet
    end
  end
end
