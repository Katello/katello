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

# Comments below are meant to describe in detail how to use elasticsearch (ES) properly. Systems
# are most commonly used as a reference for adding other model/view/controllers to katello.

# rubocop:disable SymbolName
module Katello
module Glue::ElasticSearch::System

  module ClassMethods
    def sortable_fields
      %w(name environment content_view)
    end
  end

  # rubocop:disable MethodLength
  def self.included(base)
    base.class_eval do
      include Ext::IndexedModel
      extend ClassMethods

      add_host_collection_hook     lambda { |host_collection| reindex_on_association_change(host_collection) }
      remove_host_collection_hook  lambda { |host_collection| reindex_on_association_change(host_collection) }

      # 'index_options' controls what attributes are indexed and stored in ES. From indexed_model.rb
      #  :json  - normal to_json options,  :only or :except allowed
      #  :extended_json  - function to call to return a hash to merge into document
      #  :display_attrs  - list of attributes to display as searchable
      index_options :extended_json => :extended_index_attrs,
                    :json => {:only => [:name,
                                        :description,
                                        :id,
                                        :uuid,
                                        :created_at,
                                        :lastCheckin,
                                        :environment_id,
                                        :memory,
                                        :sockets,
                                        :content_view
                      ]},
                    :display_attrs => [:name,
                                       :description,
                                       :id,
                                       :uuid,
                                       :created_at,
                                       :lastCheckin,
                                       :host_collection,
                                       :installed_products,
                                       "custom_info.KEYNAME",
                                       :content_view,
                                       :memory,
                                       :sockets,
                                       :status,
                                       :virtual_host,
                                       :virtual_guests
                    ]

      dynamic_templates = [
          {
            "fact_string" => {
              :path_match => "facts.*",
              :mapping => {
                  :type => "string",
                  :analyzer => "kt_name_analyzer"
              }
            }
          },
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

      # http://www.elasticsearch.org/guide/reference/mapping/index.html
      #
      # It is important to note that ES requires that the type of everything indexed is consistent,
      # if it is auto-determining the type. For example, if it encounters an attribute that it
      # determines is a date then later fails to parse that attribute as a date on another object,
      # searches on that field will not return any results. For best results, explicitly declaring
      # everything that is to be indexed here is best.
      #
      # Sorting only works on fields with single values (ie. w/o tokenization). Setting :not_analyzed
      # on the 'name_sort' field prevents this. This does mean that anything that needs to be sorted
      # (eg. for display in UI table) needs to have its fields duplicated if they are tokenized.
      mapping   :dynamic_templates => dynamic_templates do
        indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :description, :type => 'string'
        indexes :content_view, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :environment, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :lastCheckin, :type => 'date'
        indexes :name_autocomplete, :type => 'string', :analyzer => 'autcomplete_name_analyzer'
        indexes :installed_products, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :memory, :type => 'integer'
        indexes :sockets, :type => 'integer'
        indexes :uuid, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :facts, :path => "just_name" do
        end
        indexes :custom_info, :path => "just_name" do
        end
        indexes :status, :type => 'string'

        # Sortable attributes
        indexes :name_sort, :type => 'string', :index => :not_analyzed
        indexes :environment_sort, :type => 'string', :index => :not_analyzed
        indexes :content_view_sort, :type => 'string', :index => :not_analyzed

        indexes :virtual_host, :type => 'string', :analyzer => :kt_name_analyzer
        indexes :virtual_guests, :type => 'string', :analyzer => :kt_name_analyzer
      end

      # Whenever a system's 'name' field changes, the objects returned by system.host_collections
      # relation are themselves reindexed.
      #update_related_indexes :host_collections, :name
    end
  end

  # Additional values to index that are not available in a normal to_json call
  def extended_index_attrs
    attrs = {
      :facts => self.facts,
      :organization_id => self.organization.id,
      :host_collection => self.host_collections.collect{|g| g.name},
      :host_collection_ids => self.host_collection_ids,
      :installed_products => collect_installed_product_names,
      :sockets => self.sockets,
      :custom_info => collect_custom_info,
      :content_view => self.content_view.try(:name),
      :environment => self.environment.try(:name),
      :status => self.compliance_color,

      # Sortable attributes
      :name_sort => name.downcase, :name_autocomplete => self.name,
      :content_view_sort => self.content_view.try(:name),
      :environment_sort => self.environment.try(:name)
    }

    if self.virtual_guest
      attrs[:virtual_host] = self.virtual_host ? self.virtual_host.name : ''
    else
      attrs[:virtual_guests] = self.virtual_guests.map(&:name)
    end

    attrs
  end

  def update_host_collections
    system_id = self.id #save the system id for the block
    id_update = "ctx._source.host_collection_ids = [#{self.host_collection_ids.join(",")}]; "
    names = self.host_collections.pluck(:name).map{|name| "\"#{name}\""}
    name_update = "ctx._source.host_collection = [#{names.join(",")}];"
    Tire.index System.index.name do
      update System.document_type, system_id, {:script => id_update + name_update }
    end

  end

end
end
