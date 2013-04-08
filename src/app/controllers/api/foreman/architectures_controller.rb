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

class Api::Foreman::ArchitecturesController < Api::Foreman::SimpleCrudController

  resource_description do
    description <<-DOC
      The Architectures API is available only if support for Foreman is installed.
    DOC
  end

  self.foreman_model = ::Foreman::Architecture

  def_param_group :architecture do
    param :architecture, Hash, :desc => "architecture info", :required => true, :action_aware => true do
      param :name, String, "architecture name", :required => true
    end
  end

  api :GET, "/architectures", "Get list of architectures available in Foreman"
  def index
    super
  end

  api :GET, "/architectures/:id", "Show an architecture"
  param :id, String, "architecture name"
  def show
    super
  end

  api :POST, "/architecture", "Create new architecture in Foreman"
  param_group :architecture
  def create
    super
  end

  api :PUT, "/architectures/:id", "Update an architecture record in Foreman"
  param :id, String, "architecture name"
  param_group :architecture
  def update
    super
  end

  api :DELETE, "/architectures/:id", "Remove an architecture from Foreman"
  param :id, String, "architecture name"
  def destroy
    super
  end
end


