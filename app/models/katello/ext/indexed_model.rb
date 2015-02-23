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
  module Ext::IndexedModel
    # TODO: move methods out into submodule
    # rubocop:disable MethodLength
    def self.included(base)
      base.class_eval do
        cattr_accessor :class_index_options

        def self.display_attributes
          self.class_index_options[:display_attrs].sort { |a, b| a.to_s <=> b.to_s }
        end

        if Rails.env.development? || Rails.env.production?
          include Tire::Model::Search
          include Tire::Model::Callbacks
          index_name Katello.config.elastic_index + '_' +  self.base_class.name.downcase

          #Shared analyzers.  If you need a model-specific analyzer for some reason,
          #  we'll need to refactor this to support that.
          settings :analysis => {
            :filter => Util::Search.custom_filters,
            :analyzer => Util::Search.custom_analyzers
          }

          def self.index_import(list)
            self.index.import(list)
          end

          after_save :refresh_index

        else
          #stub mapping
          def self.mapping(*_args)
            {}
          end
          def self.index_import(_list)
          end
          def self.index_name(_name)
          end
        end

        def disable_auto_reindex!
          @disable_auto_reindex = true
        end

        def enable_auto_reindex!
          @disable_auto_reindex = false
        end

        def disable_auto_reindex_on_association!
          @disable_auto_reindex_on_association = true
        end

        def enable_auto_reindex_on_association!
          @disable_auto_reindex_on_association = false
        end

        def refresh_index
          return if @disable_auto_reindex
          self.class.index.refresh if self.class.respond_to?(:index)
        end

        ##
        #  :json  - normal to_json options,  :only or :except allowed
        #  :extended_json  - function to call to return a hash to merge into document
        #  :display_attrs  - list of attributes to display as searchable
        ##
        def self.index_options(options = {})
          self.class_index_options = options
        end

        # If this object (e.g. host_collection) is updated or deleted and another model (e.g. system) has an
        # association (e.g. has_many) to it, we need to update the related indexes on that model (e.g system)
        #   relation - the association for the other model
        #   attribute - the attribute on the current model, which if changes needs to trigger the index update
        def self.update_related_indexes(relation, attribute)
          after_save lambda { |_record| reindex_on_update(relation, attribute) }
          before_destroy lambda { |_record| save_indexed_relation(relation) }
          after_destroy lambda { |_record| reindex_relation }
        end

        # If this model (e.g. host_collection) has an association (e.g. has_many) to another model (e.g. system)
        # and objects (e.g. systems) are added or removed for that association, we need to update the related
        # indexes on that model.
        def self.update_association_indexes
          { :after_add => :reindex_on_association_change, :after_remove => :reindex_on_association_change }
        end

        def reindex_on_association_change(record)
          return if @disable_auto_reindex_on_association
          record.update_index if record.respond_to? :update_index
          record.class.index.refresh if record.class.respond_to? :index
        end

        def reindex_on_update(relation, attribute)
          return if @disable_auto_reindex
          # If the specified attribute (e.g. name) on the current model has changed, update the related indexes
          if self.send("#{attribute}_changed?")
            related_objects = self.send(relation)
            update_related_objects related_objects
          end
        end

        def save_indexed_relation(relation)
          # If an object (e.g. host_collection) is being deleted and another object (e.g. system) has a model
          # relationship (e.g. has_many :through) with it, we need to update the indexes on that other model.
          # Unfortunately, in order to do that, the update needs to be performed after this object is destroyed
          # (i.e. after_destroy); however, at that point, the object (e.g. host_collection) no longer references
          # the other (e.g. system).
          #
          # Temporarily save a list of the related objects that need indexes updated, for use in the 'after_destroy'.
          @related_objects = self.send(relation)
        end

        def reindex_relation
          update_related_objects @related_objects
        end

        def update_related_objects(objects)
          unless objects.blank?
            objects.each do |object|
              object.update_index if object.respond_to? :update_index
            end
          end
        end

        def self.use_index_of(model)
          if Rails.env.development? || Rails.env.production?
            index_name model.index_name
            document_type model.document_type
          end
        end
      end
    end

    #mocked methods for testing
    unless Rails.env.development? || Rails.env.production?
      def update_index
      end
    end

    def indexed_attributes
      attrs = self.attributes.keys.collect { |key| key.to_sym }
      attrs += self.lazy_attributes if self.respond_to?(:lazy_attributes)
      if self.class.class_index_options[:json]
        options = self.class.class_index_options[:json]
        if options[:only]
          attrs = options[:only]
        elsif options[:except]
          attrs -= options[:except]
        end
      end
      attrs
    end

    def to_indexed_json
      return {} if @disable_auto_reindex
      to_ret = {}

      attrs = self.indexed_attributes

      (attrs).each do |attr|
        to_ret[attr] = self.send(attr)
      end

      if self.class.class_index_options[:extended_json]
        to_ret.merge!(self.send(self.class.class_index_options[:extended_json]))
      end

      to_ret.to_json
    end
  end
end
