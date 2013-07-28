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

module Katello
  class Verb < ActiveRecord::Base
    has_and_belongs_to_many :permission
    validates_length_of :verb, :maximum => 255

    # alias for verb attribute
    def name
      verb
    end

    # used for user-friendly presentation of this record
    def all_display_names resource_type_name
      verbs  = Verb.verbs_for(resource_type_name, true).merge(Verb.verbs_for(resource_type_name, false))
      verbs[verb]
    end

    def display_name resource_type_name, global
      verbs  = Verb.verbs_for(resource_type_name, global)
      verbs[verb]
    end


    def self.verbs_for(resource_type_name, global = false)
      res_type = ResourceType::TYPES[resource_type_name]
      return res_type[:model].list_verbs(global) if res_type && res_type[:model]
      {}
    end

    def self.no_tag_verbs(resource_type_name)
      res_type = ResourceType::TYPES[resource_type_name]
      return res_type[:model].no_tag_verbs if res_type && res_type[:model] && res_type[:model].respond_to?('no_tag_verbs')
      {}
    end

  end
end
