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

class Foreman::Architecture < Resources::ForemanModel
  include Resources::AbstractModel::IndexedModel

  attributes :name, :operatingsystem_ids
  validates :name, :presence => true

  def json_default_options
    { :only => [:name, :operatingsystem_ids] }
  end

  index_options :display_attrs => [:name]

  mapping do
    indexes :id, :type=>'string', :index => :not_analyzed
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
  end


  def initialize(attributes = { })
    super attributes
    @operatingsystem_ids ||= []
  end

end
