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

class CustomInfo < ActiveRecord::Base
  acts_as_reportable

  attr_accessible :keyname, :value

  belongs_to :informable, :polymorphic => true

  validates :keyname, :presence => true
  validates_uniqueness_of :keyname, :scope => [:informable_type, :informable_id], :message => "already exists for this object"

  validates :informable_id, :presence => true
  validates :informable_type, :presence => true

  after_save :reindex_informable
  after_destroy :reindex_informable

  def self.find_by_informable_keyname(informable, keyname)
    return informable.custom_info.find_by_keyname(keyname)
  end

  # find the Katello object by type and ID (i.e. "system", 32)
  def self.find_informable(informable_type, informable_id)
    klass = informable_type.classify.constantize
    informable = klass.find(informable_id)
    return informable
  end

  # Apply a set of custom info to a list of objects.
  # Does not apply to a particular object if it already has custom info with the given keyname.
  # Returns a list of the objects that had at least one custom info added to them.
  def self.apply_to_set(list_of_objects, custom_info_list)
    affected = []

    list_of_objects.each do |obj|
      to_apply = custom_info_list.collect { |c| c[:keyname] } - obj.custom_info.collect { |c| c[:keyname] }

      custom_info_list.select { |c| to_apply.include?(c[:keyname]) }.each do |info|
        obj.custom_info.create!(info)
        affected << obj
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

end
