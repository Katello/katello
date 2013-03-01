#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class Api::Foreman::PartitionTablesController < Api::Foreman::SimpleCrudController

  resource_description do
    description <<-DOC
      The partition tables API is available only if support for Foreman is installed.
    DOC
  end

  self.foreman_model = ::Foreman::PartitionTable

  api :GET, "/partition_tables", "Get list of partition tables available in Foreman"
  def index
    super
  end

  api :GET, "/partition_tables/:id", "Show an partition table"
  param :id, String, "partition table name"
  def show
    super
  end

  api :POST, "/partition_tables", "Create new partition table in Foreman"
  param :partition_table, Hash, :desc => "partition table info", :required => true do
    param :name, String, :required => true
    param :layout, String, :required => true
    param :os_family, String, :required => false
  end
  def create
    super
  end

  api :PUT, "/partition_tables/:id", "Update an partition table record in Foreman"
  param :id, String, "partition table name"
  param :partition_table, Hash, :desc => "partition table info", :required => true do
    param :name, String
    param :layout, String
    param :os_family, String
  end
  def update
    super
  end

  api :DELETE, "/partition_tables/:id", "Remove an partition table from Foreman"
  param :id, String, "partition table name"
  def destroy
    super
  end
end


