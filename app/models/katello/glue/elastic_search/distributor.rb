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

# rubocop:disable SymbolName
module Katello
  module Glue::ElasticSearch::Distributor
    # TODO: break this up into modules
    # rubocop:disable MethodLength
    def self.included(base)
      base.class_eval do
        include Ext::IndexedModel

        index_options :extended_json => :extended_index_attrs,
                      :json => {:only => [:name, :description, :id, :uuid, :created_at, :lastCheckin, :environment_id]},
                      :display_attrs => [:name,
                                         :description,
                                         :id,
                                         :uuid,
                                         :created_at,
                                         :lastCheckin,
                                         "custom_info.KEYNAME"]

        dynamic_templates = [
          {
            "custom_info_string" => {
              :path_match => "custom_info.*",
              :mapping => {
                :type => "string",
                :analyzer => "kt_name_analyzer"
              }
            }
          }
        ]

        mapping :dynamic_templates => dynamic_templates do
          indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
          indexes :description, :type => 'string'
          indexes :name_sort, :type => 'string', :index => :not_analyzed
          indexes :lastCheckin, :type => 'date'
          indexes :name_autocomplete, :type => 'string', :analyzer => 'autcomplete_name_analyzer'
          indexes :custom_info, :path => "just_name" do
          end
        end
      end
    end

    def extended_index_attrs
      {:organization_id => self.organization.id,
       :name_sort => name.downcase, :name_autocomplete => self.name,
       :custom_info => collect_custom_info
      }
    end
  end
end
