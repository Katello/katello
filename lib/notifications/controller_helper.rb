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

module Notifications
  module ControllerHelper
    def notify
      @notifier ||= Notifier.new(self, default_notify_options)
    end

    private

    # define default options for Notifier instance
    # @example to set current organization as notice's organization
    #     def default_notify_options
    #       { :organization => current_organization }
    #     end
    # @example not to set any organization for a notice
    #     def default_notify_options
    #       { :organization => nil }
    #     end
    def default_notify_options
      raise NotImplementedError
    end
  end
end
