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
  module Notifications::ControllerHelper
    # defines helper to access notifications from controller
    # @example how to send notification from controller
    #   notify.success _("Welcome Back") + ", " + current_user.username, :persist => false
    #   notify.message _("'%s' no longer matches the current search criteria.") % @gpg_key["name"], :asynchronous => false
    #   notify.invalid_record @an_user
    #   notify.warning _("You must be logged in to access that page.")
    #   notify.error _("Please select at least one system group.")
    #   notify.exception an_exception
    # @see Notifier
    def notify
      @notifier ||= Notifications::Notifier.new(self, default_notify_options)
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
