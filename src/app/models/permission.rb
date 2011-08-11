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
    name = (resource_type && resource_type.name) || "all resources"
    org_id = (organization && "in organization #{organization.id}") || " across all organizations."
    "Role #{role.name}'s allowed to perform #{v} on #{t} for #{name} #{org_id}"
  end

  def to_abbrev_text
    v = (all_verbs? && "nil") || "[#{verbs.collect { |v| v.verb }.join(',')}]"
    t = (all_tags? && "nil") || "[#{tags.collect { |t| t.name }.join(',')}]"
    name = (resource_type && resource_type.name) || "nil"
    org_id = (organization && "#{organization.id}") || "nil"
    "#{v}, #{name}, #{t}, #{org_id}"
  end


  def all_types
    resource_type.nil?
  end


  private
  def cleanup_tags_verbs
    self.tags.clear if self.all_tags?
    self.verbs.clear if self.all_verbs?
  end
end
