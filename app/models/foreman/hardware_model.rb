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

class Foreman::HardwareModel < Resources::ForemanModel
  include Resources::AbstractModel::IndexedModel

  attributes :name, :info, :vendor_class, :hardware_model
  validates :name, :presence => true

  resource_name :hardware_model
  foreman_resource_name :model

  def json_default_options
    return {
      :root => resource_name,
      :only => [:name, :info, :vendor_class, :hardware_model]
    }
  end

  index_options :display_attrs => [:name]

  mapping do
    indexes :id, :type=>'string', :index => :not_analyzed
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
  end


end
