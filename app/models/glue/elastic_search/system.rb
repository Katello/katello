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


module Glue::ElasticSearch::System
  def self.included(base)
    base.class_eval do
      include IndexedModel

      update_related_indexes :system_groups, :name

      index_options :extended_json=>:extended_index_attrs,
                    :json=>{:only=> [:name, :description, :id, :uuid, :created_at, :lastCheckin, :environment_id]},
                    :display_attrs=>[:name, :description, :id, :uuid, :created_at, :lastCheckin, :system_group]

      mapping   :dynamic_templates =>[{"fact_string" => {
                              :path_match => "facts.*",
                              :mapping => {
                                  :type=>"string",
                                  :analyzer=>"kt_name_analyzer"
                              }
                            }} ] do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
        indexes :lastCheckin, :type=>'date'
        indexes :name_autocomplete, :type=>'string', :analyzer=>'autcomplete_name_analyzer'
        indexes :facts, :path=>"just_name" do
        end

      end

    end
  end

  def extended_index_attrs
    {:facts=>self.facts, :organization_id=>self.organization.id,
     :name_sort=>name.downcase, :name_autocomplete=>self.name,
     :system_group=>self.system_groups.collect{|g| g.name},
     :system_group_ids=>self.system_group_ids
    }
  end
end
