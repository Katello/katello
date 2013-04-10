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


module Glue::ElasticSearch::SystemGroup
  def self.included(base)
    base.send :include, Ext::IndexedModel

    base.class_eval do
      update_related_indexes :systems, :name

      add_system_hook     lambda { |system| reindex_on_association_change(system) }
      remove_system_hook  lambda { |system| reindex_on_association_change(system) }

      index_options :extended_json=>:extended_index_attrs,
                    :json=>{:only=>[:id, :organization_id, :name, :description, :max_systems]},
                    :display_attrs=>[:name, :description, :system]

      mapping do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :name_sort, :type => 'string', :index => :not_analyzed
        indexes :name_autocomplete, :type=>'string', :analyzer=>'autcomplete_name_analyzer'
      end
    end
  end

  def extended_index_attrs
    {:name_sort=>name.downcase, :name_autocomplete=>self.name,
     :system=>self.systems.collect{|s| s.name}
    }
  end

end
