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
  module Authentication
    module RhsmAuthentication
      extend ActiveSupport::Concern

      included do
        include ClientAuthentication

        def authorize_rhsm
          if cert_present?
            set_client_user
          elsif authenticate
            User.current
          else
            deny_access
          end
        end

        def add_candlepin_version_header
          response.headers["X-CANDLEPIN-VERSION"] = "katello/#{Katello.config.katello_version}"
        end

      end

    end
  end
end
