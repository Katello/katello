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
  class AutoCompleteSearchController < Katello::ApplicationController
    include Foreman::Controller::AutoCompleteSearch

    def model_of_controller
      Organization.current ? model.where(:organization_id => Organization.current.id) : model
    end

    def model
      Katello::Util::Model.controller_path_to_model("katello/#{params[:kt_path]}")
    end

    def permission_controller
      "katello/#{params[:kt_path]}"
    end
  end
end
