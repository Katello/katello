
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

module Actions
  module Katello
    module Provider
      class Destroy < Actions::EntryAction
        def plan(provider, check_products = true)
          fail _("Red Hat provider can not be deleted") if !provider.being_deleted? && provider.redhat_provider?
          fail _("Cannot delete provider with attached products") if check_products && !provider.products.empty?
          action_subject(provider)

          plan_self
        end

        def finalize
          provider = ::Katello::Provider.find(input[:provider][:id])
          provider.destroy!
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
