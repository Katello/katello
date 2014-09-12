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

module Katello
  module Glue::ElasticSearch::Environment
    def self.included(base)
      base.class_eval do
        include Ext::IndexedModel
        after_save :update_related_index

        index_options :extended_json => :extended_index_attrs,
          :json => {:only => [:id, :name, :description, :organization_id]},
          :display_attrs => [:name, :description]

        mapping do
          indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
          indexes :name_sort, :type => 'string', :index => :not_analyzed
          indexes :label, :type => 'string', :index => :not_analyzed
          indexes :library, :type => 'boolean'
          indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
          indexes :name_autocomplete, :type => 'string', :analyzer => 'autcomplete_name_analyzer'
        end

        def extended_index_attrs
          {
            :name_sort => name.downcase,
            :library => self.library?,
            :name_autocomplete => self.name,
            :organization_id => organization.id
          }
        end
      end
    end

    def update_related_index
      if self.name_changed?
        self.organization.reload #must reload organization, otherwise old name is saved
        self.organization.update_index
        ActivationKey.index.import(self.activation_keys) if !self.activation_keys.empty?
      end
    end
  end
end
