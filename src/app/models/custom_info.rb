require 'set'

class CustomInfo < ActiveRecord::Base
  acts_as_reportable

  belongs_to :informable, :polymorphic => true

  validates :keyname, :presence => true
  validates_uniqueness_of :keyname, :scope => [:value, :informable_type, :informable_id], :message => "already exists for this object"

  validates :informable_id, :presence => true
  validates :informable_type, :presence => true

  # Apply a set of custom info to a list of objects.
  # Does not apply to a particular object if it already has custom info with the given keyname.
  # Returns a list of the objects that had at least one custom info added to them.
  def self.apply_to_set(list_of_objects, custom_info_list)
    affected = []

    list_of_objects.each do |obj|
      to_apply = custom_info_list.collect {|c| c[:keyname]} - obj.custom_info.collect {|c| c[:keyname]}

      custom_info_list.select {|c| to_apply.include?(c[:keyname])}.each do |info|
        obj.custom_info.create!(info)
        affected << obj
      end

    end

    return affected.uniq
  end
end
