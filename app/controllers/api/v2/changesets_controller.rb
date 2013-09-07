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

class Api::V2::ChangesetsController < Api::V1::ChangesetsController

  include Api::V2::Rendering

  resource_description do
    api_version "v2"
  end

  def_param_group :changeset do
    param :changeset, Hash, :required => true, :action_aware => true do
      param :name, String, :desc => "The name of the changeset", :required => true
      param :description, String, :desc => "The description of the changeset"
    end
  end

  api :GET, "/environments/:environment_id/changesets", "List changesets in an environment"
  param :name, String, :desc => "An optional changeset name to filter upon"
  def index
    super
  end

  api :GET, "/changesets/:id", "Show a changeset"
  def show
    respond
  end

  api :POST, "/environments/:environment_id/changesets", "Create a changeset"
  param_group :changeset
  param :changeset, Hash do
    param :type, Changeset::TYPES, :required => true
  end
  def create
    super
  end

end
