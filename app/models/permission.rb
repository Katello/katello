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

class Permission < ActiveRecord::Base
  belongs_to :resource_type
  belongs_to :organization
  belongs_to :role, :inverse_of => :permissions
  has_and_belongs_to_many :verbs
  has_and_belongs_to_many :tags

  before_save :cleanup_tags_verbs

  validates :name, :presence => true

  class PermissionValidator < ActiveModel::Validator
    def validate(record)
      if record.all_verbs? && !record.verbs.empty?
        record.errors[:base] << N_("Cannot specify a verb if all_verbs is selected.")
      end

      if record.all_tags? && !record.tags.empty?
        record.errors[:base] << N_("Cannot specify a tag if all_tags is selected.")
      end

      if record.all_types? && (!record.all_verbs? || !record.all_tags?)
        record.errors[:base] << N_("Cannot specify all_types without all_tags and all_verbs")
      end

      begin
        ResourceType.check(record.resource_type.name, record.verb_values)
      rescue VerbNotFound => verb_error
        record.errors[:base] << verb_error.message
      rescue ResourceTypeNotFound => type_error
        record.errors[:base] << type_error.message
      end
    end
  end


  validates_with PermissionValidator
  validates_presence_of :resource_type

  def tag_names
    self.tags.collect {|tag| tag.name}
  end

  def tag_names=attributes
    self.tags = attributes.collect do |tag|
      Tag.find_or_create_by_name(tag)
    end
  end


  def verb_values
    self.verbs.collect {|verb| verb.verb}
  end

  def verb_values=attributes
    self.verbs = attributes.collect do |verb|
      Verb.find_or_create_by_verb(verb)
    end
  end

  def resource_type_attributes=(attributes)
    self.resource_type= ResourceType.find_or_create_by_name(attributes[:name])
  end

  def to_text
    v = (all_verbs? && "any action") || verbs.collect { |v| v.verb }.join(',')
    t = (all_tags? && "all scopes") || "scopes #{tags.collect { |t| t.name }.join(',')}"
    name = (all_types? && "all_resources") || resource_type.name
    org_id = (organization && "in organization #{organization.id}") || " across all organizations."
    "Role #{role.name}'s allowed to perform #{v} on #{t} for #{name} #{org_id}"
  end

  def to_abbrev_text
    v = (all_verbs? && "all_verbs") || "[#{verbs.collect { |v| v.verb }.join(',')}]"
    t = (all_tags? && "all_tags") || "[#{tags.collect { |t| t.name }.join(',')}]"
    name = (all_types? && "all_resources") || resource_type.name
    org_id = (organization && "#{organization.id}") || "all organizations"
    "#{v}, #{name}, #{t}, #{org_id}"
  end

  def display_verbs global = false
    return {all_verbs => true}.with_indifferent_access if all_verbs
    return {} if resource_type.nil? || verbs.nil?
    display_verbs = {}
    verbs.each { |verb|
      display_verbs[verb.verb] = {:id => verb.id, :display_name => verb.display_name(resource_type.name, global)}
    }
    display_verbs.with_indifferent_access
  end

  def all_types?
   (!resource_type.nil?) && :all.to_s == resource_type.name
  end

  def all_types= types
    if types
      self.all_tags=true
      self.all_verbs=true
      self.verbs.clear
      self.tags.clear
      self.resource_type = ResourceType.find_or_create_by_name(:all)
    end
  end

  private
  def cleanup_tags_verbs
    self.tags.clear if self.all_tags?
    self.verbs.clear if self.all_verbs?
  end



end


