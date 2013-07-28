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
  class CustomInfo < ActiveRecord::Base
    acts_as_reportable

    attr_accessible :keyname, :value, :org_default

    belongs_to :informable, :polymorphic => true

    validates :keyname, :presence => true
    validates :keyname, :length => { :maximum => 255 }
    validates_uniqueness_of :keyname, :scope => [:informable_type, :informable_id], :message => "already exists for this object"

    validates :value, :length => { :maximum => 255 }

    validates :informable_id, :presence => true
    validates :informable_type, :presence => true

    before_validation :strip_attributes
    after_save :reindex_informable

    def self.find_by_informable_keyname(informable, keyname)
      return informable.custom_info.find_by_keyname(keyname)
    end

    # find the Katello object by type and ID (i.e. "system", 32)
    def self.find_informable(informable_type, informable_id)
      class_name = informable_type.classify
      informable = class_name.constantize.find(informable_id)
      raise _("Resource %s does not support custom information") % class_name unless informable.respond_to? :custom_info
      return informable
    end

    def self.apply_to_set(ids_and_types, custom_info_list)
      list_of_objects = ids_and_types.inject([]) do |collection, obj|
        collection << CustomInfo.find_informable(obj[:informable_type], obj[:informable_id])
      end

      affected = []
      list_of_objects.each do |obj|

        to_apply = custom_info_list.collect { |c| c[:keyname] } - obj.custom_info.collect { |c| c[:keyname] }
        custom_info_list.select { |c| to_apply.include?(c[:keyname]) }.each do |info|
          info[:org_default] = true
          obj.custom_info.create!(info)
          affected << { :informable_type => obj.class.name, :informable_id => obj.id }
        end

        to_remove = obj.custom_info.select { |c| c[:org_default] }.collect { |c| c[:keyname] } - custom_info_list.collect { |c| c[:keyname] }
        to_remove.each do |key|
          ci = obj.custom_info.find_by_keyname(key)
          ci.destroy
          affected << { :informable_type => obj.class.name, :informable_id => obj.id }
        end

      end
      return affected.uniq
    end

    def reindex_informable
      self.informable.class.index.import([self.informable])
    end

    def to_s
      "#{self.keyname}: #{self.value.nil? ? _("NOT-SPECIFIED") : self.value}"
    end

    def <=>(obj)
      return self.keyname <=> obj.keyname
    end

    private

    def strip_attributes
      self.keyname.try(:strip!)
      self.value.try(:strip!)
    end

  end
end
