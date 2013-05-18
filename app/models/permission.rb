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

class Permission < ActiveRecord::Base
  include Glue::ElasticSearch::Permission if Katello.config.use_elasticsearch
  before_destroy :check_locked # RAILS3458: must be before dependent associations http://tinyurl.com/rails3458
  belongs_to :resource_type
  belongs_to :organization
  belongs_to :role, :inverse_of => :permissions
  has_and_belongs_to_many :verbs
  has_many :tags, :class_name=>"PermissionTag", :dependent => :destroy, :inverse_of=>:permission

  before_save :cleanup_tags_verbs
  before_save :check_global


  validates :name, :presence => true
  validates_with Validators::NonHtmlNameValidator, :attributes => :name
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates_uniqueness_of :name, :scope => [:organization_id, :role_id], :message => N_("Label has already been taken")
  validates_with Validators::PermissionValidator
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
    verbs.each do |verb|
      display_verbs[verb.verb] = {:id => verb.id, :display_name => verb.display_name(resource_type.name, global)}
    end
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
      when "Read Providers"
        _("Read Providers")
      when "Read Activation_keys"
        _("Read Activation Keys")
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
      when "Read Providers permission"
        _("Read Providers permission")
      when "Read Activation_keys permission"
        _("Read Activation Keys permission")
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



  def check_locked
    if self.role.locked?
      raise ActiveRecord::ReadOnlyRecord, _("Cannot add/remove or change permissions related to a locked role.")
    end
  end

end


