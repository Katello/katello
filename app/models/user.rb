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

require 'ldap'
require 'util/threadsession'
require 'util/password'

class User < ActiveRecord::Base
  has_many :roles_users
  has_many :roles, :through => :roles_users
  belongs_to :own_role, :class_name => 'Role'
  has_many :help_tips
  has_many :user_notices
  has_many :notices, :through => :user_notices
  has_many :search_favorites, :dependent => :destroy
  has_many :search_histories, :dependent => :destroy


  validates :username, :uniqueness => true, :presence => true, :username => true
  validate :own_role_included_in_roles

  # check if the role does not already exist for new username
  validates_each :username do |model, attr, value|
    if model.new_record? and Role.find_by_name(value)
      model.errors.add(:username, "role with the same name '#{value}' already exists")
    end
  end


  scoped_search :on => :username, :complete_value => true, :rename => :name
  scoped_search :in => :roles, :on => :name, :complete_value => true, :rename => :role

  # validate the password length before hashing
  validates_each :password do |model, attr, value|
    if model.password_changed?
      model.errors.add(attr, "at least 5 characters") if value.length < 5
    end
  end

  # hash the password before creating or updateing the record
  before_save do |u|
    u.password = Password::update(u.password) if u.password.length != 192
  end

  # create own role for new user
  after_create do |u|
    if u.own_role.nil?
      # create the own_role where the name will be a string consisting of username and 20 random chars
      r = Role.create!(:name => "#{u.username}_#{Password.generate_random_string(20)}")
      u.roles << r unless u.roles.include? r
      u.own_role = r
      u.save!
    end
  end

  # THIS CHECK MUST BE THE FIRST before_destroy
  # check if this is not the last superuser
  before_destroy do |u|
    if u.superadmin? and User.joins(:roles).where(:roles => {:superadmin => true}).count == 1
      u.errors.add(:base, "cannot delete last admin user")
      false
    else
      true
    end
  end

  # destroy own role for user
  before_destroy do |u|
    u.own_role.destroy
    unless u.own_role.destroyed?
      Rails.logger.error error.to_s
    end
  end

  # support for session (thread-local) variables
  include Katello::ThreadSession::UserModel
  include Ldap

  # return the special "nobody" user account
  def self.anonymous
    find_by_username('anonymous')
  end

  def self.authenticate!(username, password)
    u = User.where({:username => username}).first
    # check if user exists
    return nil unless u
    # check if not disabled
    return nil if u.disabled
    # check if hash is valid
    return nil unless Password.check(password, u.password)
    u
  end

  def self.authenticate_using_ldap!(username, password)
    if Ldap.valid_ldap_authentication? username, password
      User.new :username => username
    else
      nil
    end
  end

  # Returns true if for a given verbs, resource_type org combination
  # the user has access to all the tags
  # This is used extensively in many of the model permission scope queries.
  def allowed_all_tags?(verbs, resource_type,  org = nil)
    ResourceType.check resource_type, verbs
    verbs = [] if verbs.nil?
    verbs = [verbs] unless verbs.is_a? Array
    org = Organization.find(org) if Numeric === org
    Rails.logger.debug "Checking if user #{username} is allowed to #{verbs.join(',')} in
          #{resource_type.inspect} in organization #{org && org.inspect}"

    org_permissions = org_permissions_query(org, resource_type == :organizations)
    org_permissions = org_permissions.where(:organization_id => nil) if resource_type == :organizations


    verbs = verbs.collect {|verb| action_to_verb(verb, resource_type)}
    no_tag_verbs = ResourceType::TYPES[resource_type][:model].no_tag_verbs rescue []
    no_tag_verbs ||= []
    no_tag_verbs.delete_if{|verb| !verbs.member? verb}
    verbs.delete_if{|verb| no_tag_verbs.member? verb}

    all_tags_clause = ""
    unless resource_type == :organizations || ResourceType.global_types.include?(resource_type.to_s)
      all_tags_clause = " AND (permissions.all_tags = :true)"
    end

    clause_all_resources_or_tags = %{permissions.resource_type_id  = (select id from resource_types where resource_types.name = :all) OR
          (permissions.resource_type_id = (select id from resource_types where
            resource_types.name = :resource_type) AND
           (verbs.verb in (:no_tag_verbs) OR
            (permissions.all_verbs=:true OR verbs.verb in (:verbs) #{all_tags_clause} )))}.split.join(" ")
    clause_params = {:true => true, :all =>"all",  :resource_type=>resource_type, :verbs=> verbs}

    org_permissions.where(clause_all_resources_or_tags,
                                      {:no_tag_verbs => no_tag_verbs}.merge(clause_params) ).count > 0
  end

  # Class method that has the same functionality as allowed_all_tags? method but operates
  # on the current logged user. The class attribute User.current must be set!
  # If the current user is not set (is nil) it treats it like the 'anonymous' user.
  def self.allowed_all_tags?(verb, resource_type = nil, org = nil)
    u = User.current
    u = User.anonymous if u.nil?
    raise ArgumentError, "current user is not set" if u.nil? or not u.is_a? User
    u.allowed_all_tags?(verb, resource_type, org)
  end


  # Return the sql that shows all the allowed tags for a given verb, resource_type, org
  # combination .
  # Note: one needs generally check for "allowed_all_tags?" before executing this
  # Note: This returns the SQL not result of the query
  #
  # This method is called by every Model's list method
  def allowed_tags_sql(verbs=nil, resource_type = nil,  org = nil)
    select_on = "DISTINCT(tags.name)"
    select_on = "DISTINCT(permissions.organization_id)" if resource_type == :organizations

    allowed_tags_query(verbs, resource_type, org, false).select(select_on).to_sql
  end


  # Class method that has the same functionality as allowed_tags_sql method but operates
  # on the current logged user. The class attribute User.current must be set!
  # If the current user is not set (is nil) it treats it like the 'anonymous' user.
  def self.allowed_tags_sql(verb, resource_type = nil, org = nil)
    ResourceType.check resource_type, verb
    u = User.current
    u = User.anonymous if u.nil?
    raise ArgumentError, "current user is not set" if u.nil? or not u.is_a? User
    u.allowed_tags_sql(verb, resource_type, org)
  end


  # Return true if the user is allowed to do the specified action for a resource type
  # verb/action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  #
  # This method is called by every protected controller.
  def allowed_to?(verbs, resource_type, tags = nil, org = nil)
    ResourceType.check resource_type, verbs
    verbs = [] if verbs.nil?
    verbs = [verbs] unless verbs.is_a? Array
    Rails.logger.debug "Checking if user #{username} is allowed to #{verbs.join(',')} in
          #{resource_type.inspect} scoped #{tags.inspect} in organization #{org && org.inspect}"

    return true if allowed_all_tags?( verbs,resource_type, org)


    tags = [] if tags.nil?
    tags = [tags] unless tags.is_a? Array

    tags_query = allowed_tags_query(verbs, resource_type, org)

    if tags.empty? || resource_type == :organizations
      to_count = "permissions.id"
    else
      to_count = "tags.name"
    end

    tags_query = tags_query.where({:tags=> {:name=> tags.collect{|tg| tg.to_s}}}) unless tags.empty?
    count = tags_query.count(to_count, :distinct => true)
    if tags.empty?
      count > 0
    else
      tags.length == count
    end
  end

  # Class method that has the same functionality as allowed_to? method but operates
  # on the current logged user. The class attribute User.current must be set!
  # If the current user is not set (is nil) it treats it like the 'anonymous' user.
  def self.allowed_to?(verb, resource_type = nil, tags = nil, org = nil)
    u = User.current
    u = User.anonymous if u.nil?
    raise ArgumentError, "current user is not set" if u.nil? or not u.is_a? User
    u.allowed_to?(verb, resource_type, tags, org)
  end

  # Class method with the very same functionality as allowed_to? but throws
  # SecurityViolation exception leading to the denial page.
  def self.allowed_to_or_error?(verb, resource_type = nil, tags = nil)
    u = User.current
    raise ArgumentError, "current user is not set" if u.nil? or not u.is_a? User
    unless u.allowed_to?(verb, resource_type, tags)
      msg = "User #{u.username} is not allowed to #{verb} in #{resource_type} using #{tags}"
      Rails.logger.error msg
      raise Errors::SecurityViolation, msg
    end
  end

  def allowed_organizations
    #test for all orgs
    perms = Permission.joins(:role).joins("INNER JOIN roles_users ON roles_users.role_id = roles.id").
        where("roles_users.user_id = ?", self.id).where(:organization_id => nil).count()
    return Organization.all if perms > 0

    perms = Permission.joins(:role).joins("INNER JOIN roles_users ON roles_users.role_id = roles.id").
        where("roles_users.user_id = ?", self.id).where("organization_id NOT ?", nil)
    #return the individual organizations
    perms.collect{|perm| perm.organization}.uniq
  end
  


  def disable_helptip(key)
    return if !self.helptips_enabled? #don't update helptips if user has it disabled
    return if not HelpTip.where(:key => key, :user_id => self.id).empty?
    help = HelpTip.new
    help.key = key
    help.user = self
    help.save
  end

  #Remove up to 5 un-viewed notices
  def pop_notices
    to_ret = user_notices.where(:viewed=>false).limit(5)
    to_ret.each{|item| item.update_attributes!(:viewed=>true)}
    to_ret.collect{|notice| {:text=>notice.notice.text, :level=>notice.notice.level}}
  end

  def enable_helptip(key)
    return if !self.helptips_enabled? #don't update helptips if user has it disabled
    help =  HelpTip.where(:key => key, :user_id => self.id).first
    return if help.nil?
    help.destroy
  end

  def clear_helptips
    HelpTip.destroy_all(:user_id=>self.id)
  end

  def helptip_enabled?(key)
    return self.helptips_enabled && HelpTip.where(:key => key, :user_id => self.id).first.nil?
  end

  def defined_roles
    self.roles - [self.own_role]
  end

  def defined_role_ids
    self.role_ids - [self.own_role_id]
  end

  def cp_oauth_header
    { 'cp-user' => self.username }
  end

  def pulp_oauth_header
    { 'pulp-user' => self.username }
  end


  def self.list_verbs global = false
    {
    :create => N_("Create Users"),
    :read => N_("Access Users"),
    :update => N_("Update Users"),
    :delete => N_("Delete Users")
    }.with_indifferent_access
  end

  def self.no_tag_verbs
    [:create]
  end

  READ_PERM_VERBS = [:read,:update, :create,:delete]
  scope :readable, lambda {where("0 = 1")  unless User.allowed_all_tags?(READ_PERM_VERBS, :users)}

  def self.creatable?
    User.allowed_to?([:create], :users, nil)
  end

  def self.any_readable?
    User.allowed_to?(READ_PERM_VERBS, :users, nil)
  end

  def readable?
    User.any_readable?
  end

  def editable?
    User.allowed_to?([:create, :update], :users, nil)
  end

  def deletable?
    User.allowed_to?([:delete], :users, nil)
  end


  protected

  def own_role_included_in_roles
    unless own_role.nil?
      errors.add(:own_role, 'own role must be included in roles') unless roles.include? own_role
    end
  end

  DEFAULT_VERBS = {
    :destroy => 'delete', :destroy_favorite => 'delete'
  }.with_indifferent_access

  ACTION_TO_VERB = {
    :owners => {:import_status => 'read'},
  }.with_indifferent_access

  def action_to_verb(verb, type)
    return ACTION_TO_VERB[type][verb] if ACTION_TO_VERB[type] and ACTION_TO_VERB[type][verb]
    return DEFAULT_VERBS[verb] if DEFAULT_VERBS[verb]
    verb
  end

  private

  def allowed_tags_query(verbs, resource_type,  org = nil, allowed_to_check = true)
    ResourceType.check resource_type, verbs
    verbs = [] if verbs.nil?
    verbs = [verbs] unless verbs.is_a? Array
    Rails.logger.debug "Checking if user #{username} is allowed to #{verbs.join(',')} in
          #{resource_type.inspect} in organization #{org && org.inspect}"
    org = Organization.find(org) if Numeric === org
    org_permissions = org_permissions_query(org, resource_type == :organizations)

    verbs = verbs.collect {|verb| action_to_verb(verb, resource_type)}
    clause = ""
    clause_params = {:all => "all",:true => true, :resource_type=>resource_type, :verbs=> verbs}

    unless resource_type == :organizations
      clause = %{permissions.resource_type_id = (select id from resource_types where resource_types.name = :resource_type) AND
      (permissions.all_verbs=:true OR verbs.verb in (:verbs))}.split.join(" ")

      org_permissions =  org_permissions.joins("left outer join permissions_tags on permissions.id = permissions_tags.permission_id").joins(
                      "left outer join tags on tags.id = permissions_tags.tag_id")
    else
      if allowed_to_check
        org_clause = "permissions.organization_id is null"
        org_clause = org_clause + " OR permissions.organization_id = :organization_id " if org
        org_hash = {}
        org_hash = {:organization_id => org.id} if org
        org_permissions = org_permissions.where(org_clause, org_hash)
      else
        org_permissions = org_permissions.where("permissions.organization_id is not null")
      end

      clause = %{ permissions.resource_type_id = (select id from resource_types where resource_types.name = :all) OR
                      (permissions.resource_type_id = (select id from resource_types where resource_types.name = :resource_type) AND
                          (permissions.all_verbs=:true OR verbs.verb in (:verbs))
                      )
                  }.split.join(" ")
    end
    org_permissions.where(clause, clause_params)
  end


  def org_permissions_query(org, exclude_orgs_clause = false)
    org_clause = "permissions.organization_id is null"
    org_clause = org_clause + " OR permissions.organization_id = :organization_id " if org
    org_hash = {}
    org_hash = {:organization_id => org.id} if org
    query =  Permission.joins(:role).joins(
                  "INNER JOIN roles_users ON roles_users.role_id = roles.id").joins(
                  "left outer join permissions_verbs on permissions.id = permissions_verbs.permission_id").joins(
                  "left outer join verbs on verbs.id = permissions_verbs.verb_id").where({"roles_users.user_id" => id})
    return query.where(org_clause, org_hash) unless exclude_orgs_clause
    query
  end

end
