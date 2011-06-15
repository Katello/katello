#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require_dependency "resources/pulp"

class Glue::Pulp::Distribution
  attr_accessor :id, :description, :files

  def initialize(attrs = {})
    
    attrs.each_pair do |k,v| 
      if Glue::Pulp::Distribution.method_defined? k and not v.nil?
        instance_variable_set("@#{k}", v) if Glue::Pulp::Distribution.method_defined? k
      end
    end
  end

  def self.find id
    Glue::Pulp::Distribution.new(Pulp::Distribution.find(id))
  end
  
end