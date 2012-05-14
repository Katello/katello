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
  has_many :tags, :class_name=>"PermissionTag", :inverse_of=>:permission

  before_save :cleanup_tags_verbs
  before_save :check_global
  after_save :update_related_index
  
  validates :name, :presence => true, :katello_name_format => true
  validates :description, :katello_description_format => true
  validates_uniqueness_of :name, :scope => [:organization_id, :role_id], :message => N_("must be unique within an organization scope")

  before_destroy :check_locked

  before_destroy do |p|
    p.tags.destroy_all
  end


  class PermissionValidator < ActiveModel::Validator
    def validate(record)
      if record.role.locked?
        record.errors[:base] << _("Cannot add/remove or change permissions related to a locked role.")
      end

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

  def tag_values
    self.tags.collect{|t| t.tag_id}
  end

  def tag_values= attributes
    self.tags = attributes.collect {|tag| PermissionTag.new(:permission_id => id, :tag_id => tag)}
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

  def to_short_text
    v = (all_verbs? && "any action") || (verbs.empty? && "no action") || verbs.collect { |v| v.verb }.join(',')
    t = (all_tags? && "on all scopes") || (tags.empty? && "") || "on scopes #{tags.join(',')}"
    name = (all_types? && "all_resources") || resource_type.name
    org_id = (organization && "in organization #{organization.id}") || " across all orgs"
    "#{v} #{t} for #{name} #{org_id}".split.join(' ') # remove double whitespace
  end

  def to_text
    "Role #{role.name}'s allowed to perform #{to_text}"
  end

  def to_abbrev_text
    v = (all_verbs? && "all_verbs") || "[#{verbs.collect { |v| v.verb }.join(',')}]"
    t = (all_tags? && "all_tags") || "[#{tags.join(',')}]"
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

  def as_json(*args)
    ret = super.as_json(*args)
    ret[:tags] = self.tags.collect do |t|
        t[:formatted] = Tag.formatted(self.resource_type.name, t.tag_id)
        t
    end
    ret[:verbs] = self.verbs
    ret[:resource_type] = self.resource_type
    ret
  end

  # Used when displaying the localized version of permissions and
  # to insure these string make it into locale files
  def i18n_name
    case name
      when "Read Organizations"
        _("Read Organizations")
      when "Read Environments"
        _("Read Environments")
      when "Read System_templates"
        _("Read System Templates")
      when "Read Providers"
        _("Read Providers")
      when "Read Activation_keys"
        _("Read Activation Keys")
      when "Read Filters"
        _("Read Filters")
      when "Read Users"
        _("Read Users")
      when "Read Roles"
        _("Read Roles")
      when "super-admin-perm"
        _("Super Admin")
      else
        name
    end
  end

  def i18n_description
    case description
      when "Read Organizations permission"
        _("Read Organizations permission")
      when "Read Environments permission"
        _("Read Environments permission")
      when "Read System_templates permission"
        _("Read System Templates permission")
      when "Read Providers permission"
        _("Read Providers permission")
      when "Read Activation_keys permission"
        _("Read Activation Keys permission")
      when "Read Filters permission"
        _("Read Filters permission")
      when "Read Users permission"
        _("Read Users permission")
      when "Read Roles permission"
        _("Read Roles permission")
      when "Super Admin permission"
        _("Super Admin permission")
      else
        description
    end
  end

  private
  def cleanup_tags_verbs
    self.tags.clear if self.all_tags?
    self.verbs.clear if self.all_verbs?
  end

  def check_global
    unless self.organization_id
      self.all_tags = true
    end
  end

  def update_related_index
    if self.name_changed?
      self.role.update_index
    end
  end


  def check_locked
    if self.role.locked?
      raise ActiveRecord::ReadOnlyRecord, _("Cannot add/remove or change permissions related to a locked role.")
    end
  end

end


