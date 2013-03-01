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

class Foreman::PartitionTable < Resources::ForemanModel
  include Resources::AbstractModel::IndexedModel

  attributes :name, :layout, :os_family
  validates :name, :layout, :presence => true

  resource_name :partition_table
  foreman_resource_name :ptable

  def json_default_options
    return {
      :root => resource_name,
      :only => [:name, :layout, :os_family]
    }
  end

  index_options :display_attrs => [:name]

  mapping do
    indexes :id, :type=>'string', :index => :not_analyzed
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
  end


end
