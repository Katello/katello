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
  class EnvironmentsController < Katello::ApplicationController
    def rules
      {
          :registerable_paths => lambda{ true }
      }
    end

    # GET /environments/registerable_paths
    def registerable_paths
      paths = environment_paths(library_path_element("systems_readable?"),
                                environment_path_element("systems_readable?"))
      respond_to do |format|
        format.json { render :json => paths }
      end
    end

  end
end
