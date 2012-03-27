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
require 'util/notices'

class User < ActiveRecord::Base
  include Glue::Pulp::User if (AppConfig.use_cp and AppConfig.use_pulp)
  include Glue if AppConfig.use_cp
  include AsyncOrchestration
  include Katello::Notices
  include IndexedModel


  acts_as_reportable

  index_options :extended_json=>:extended_index_attrs,
                :display_attrs=>[:username, :email],
                :json=>{:except=>[:password, :password_reset_token,
                                  :password_reset_sent_at, :helptips_enabled,
                                  :disabled, :own_role_id, :login]}

  mapping do
    indexes :username, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :username_sort, :type => 'string', :index => :not_analyzed
  end

  scope :hidden, where(:hidden=>true)
  scope :visible, where(:hidden=>false)

  has_many :roles_users
  has_many :roles, :through => :roles_users, :before_remove=>:super_admin_check
  belongs_to :own_role, :class_name => 'Role'
  has_many :help_tips
  has_many :user_notices
  has_many :notices, :through => :user_notices
  has_many :search_favorites, :dependent => :destroy
  has_many :search_histories, :dependent => :destroy
  serialize :preferences, HashWithIndifferentAccess

  validates :username, :uniqueness => true, :presence => true, :username => true, :length => { :maximum => 255 }
  validates_presence_of :email

  validate :own_role_included_in_roles

  # check if the role does not already exist for new username
  validates_each :username do |model, attr, value|
    if model.new_record? and Role.find_by_name(value)
      model.errors.add(:username, "role with the same name '#{value}' already exists")
    end
  end


  # validate the password length before hashing
  validates_each :password do |model, attr, value|
    if model.password_changed?
      model.errors.add(attr, _("must be at least 5 characters.")) if value.length < 5
    end
  end

#  validates_each :own_role do |model, attr, value|
#    #This is enforced throught a user's self role where a permission with a tag is created
#    #that has the environment id of the default environment for the user
#    err_msg =  _("A user must have a default org and environment associated.")
#    if model.blank?
#      model.errors.add(attr,err_msg)
#    else
#      perm = Permission.find_all_by_role_id(@user.own_role.id)
#      if perm.blank?
#        model.errors.add(attr,err_msg)
#      else
#        if !perm[0].tags
#          model.errors.add(attr,err_msg)
#        end
#      end
#    end
#  end

  # hash the password before creating or updateing the record
  before_save do |u|
    u.password = Password::update(u.password) if u.password.length != 192
    u.preferences=HashWithIndifferentAccess.new unless u.preferences
  end

  # create own role for new user
  before_save do |u|
    if u.new_record? and u.own_role.nil?
      # create the own_role where the name will be a string consisting of username and 20 random chars
      r = Role.create!(:name => "#{u.username}_#{Password.generate_random_string(20)}", :self_role=>true)
      u.roles << r unless u.roles.include? r
      u.own_role = r
#      u.save!
    end
  end


  # THIS CHECK MUST BE THE FIRST before_destroy
  # check if this is not the last superuser
  before_destroy do |u|
    if u.id == User.current.id
      u.errors.add(:base, _("Cannot delete currently logged user"))
      false
    end
    unless u.can_be_deleted?
      u.errors.add(:base, "cannot delete last admin user")
      false
    end
    true
  end

  # destroy own role for user
  before_destroy do |u|
    u.own_role.destroy
    unless u.own_role.destroyed?
      Rails.logger.error error.to_s
    end
    u.roles.clear
  end

  # support for session (thread-local) variables
  include Katello::ThreadSession::UserModel
  include Ldap



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
  
  # if the user authenticates with LDAP, log them in
  def self.authenticate_using_ldap!(username, password)
    if Ldap.valid_ldap_authentication? username, password
      u = User.where({:username => username}).first || create_ldap_user!(username)
    else
      nil
    end
    u
  end

  # an ldap user still needs a katello model
  def self.create_ldap_user!(username)
    # user gets a dummy password and email
    User.create!(:username => username, :email => "#{username}@ldap.net", :password => 'ldapldap')
  end

  # Returns true if for a given verbs, resource_type org combination
  # the user has access to all the tags
  # This is used extensively in many of the model permission scope queries.
  def allowed_all_tags?(verbs, resource_type,  org = nil)
    ResourceType.check resource_type, verbs
    verbs = [] if verbs.nil?
    verbs = [verbs] unless verbs.is_a? Array
    org = Organization.find(org) if Numeric === org

    log_roles(verbs, resource_type, nil,org)

    org_permissions = org_permissions_query(org, resource_type == :organizations)
    org_permissions = org_permissions.where(:organization_id => nil) if resource_type == :organizations


    verbs = verbs.collect {|verb| action_to_verb(verb, resource_type)}
    no_tag_verbs = ResourceType::TYPES[resource_type][:model].no_tag_verbs.clone rescue []
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
  def self.allowed_all_tags?(verb, resource_type = nil, org = nil)
    u = User.current
    raise Errors::UserNotSet, "current user is not set" if u.nil? or not u.is_a? User
    u.allowed_all_tags?(verb, resource_type, org)
  end


  # Return the sql that shows all the allowed tags for a given verb, resource_type, org
  # combination .
  # Note: one needs generally check for "allowed_all_tags?" before executing this
  # Note: This returns the SQL not result of the query
  #
  # This method is called by every Model's list method
  def allowed_tags_sql(verbs=nil, resource_type = nil,  org = nil)
    select_on = "DISTINCT(permission_tags.tag_id)"
    select_on = "DISTINCT(permissions.organization_id)" if resource_type == :organizations

    allowed_tags_query(verbs, resource_type, org, false).select(select_on).to_sql
  end


  # Class method that has the same functionality as allowed_tags_sql method but operates
  # on the current logged user. The class attribute User.current must be set!
  def self.allowed_tags_sql(verb, resource_type = nil, org = nil)
    ResourceType.check resource_type, verb
    u = User.current
    raise Errors::UserNotSet, "current user is not set" if u.nil? or not u.is_a? User
    u.allowed_tags_sql(verb, resource_type, org)
  end


  # Return true if the user is allowed to do the specified action for a resource type
  # verb/action can be:
  # * a parameter-like Hash (eg. :controller => 'projects', :action => 'edit')
  # * a permission Symbol (eg. :edit_project)
  #
  # This method is called by every protected controller.
  def allowed_to?(verbs, resource_type, tags = nil, org = nil, any_tags = false)
    tags = [] if tags.nil?
    tags = [tags] unless tags.is_a? Array
    raise  ArgumentError, "Tags need to be integers - #{tags} are not."  if
               tags.detect{|tag| !(Numeric === tag ||(String === tag && /^\d+$/=== tag.to_s))}
    ResourceType.check resource_type, verbs
    verbs = [] if verbs.nil?
    verbs = [verbs] unless verbs.is_a? Array
    log_roles(verbs, resource_type, tags,org, any_tags)

    return true if allowed_all_tags?( verbs,resource_type, org)


    tags_query = allowed_tags_query(verbs, resource_type, org)

    if tags.empty? || resource_type == :organizations
      to_count = "permissions.id"
    else
      to_count = "permission_tags.tag_id"
    end

    tags_query = tags_query.where("permission_tags.tag_id in (:tags)", :tags=>tags) unless tags.empty?
    count = tags_query.count(to_count, :distinct => true)
    if tags.empty? || any_tags
      count > 0
    else
      tags.length == count
    end
  end

  # Class method that has the same functionality as allowed_to? method but operates
  # on the current logged user. The class attribute User.current must be set!
  def self.allowed_to?(verb, resource_type, tags = nil, org = nil, any_tags = false)
    u = User.current
    raise Errors::UserNotSet, "current user is not set" if u.nil? or not u.is_a? User
    u.allowed_to?(verb, resource_type, tags, org, any_tags)
  end

  # Class method with the very same functionality as allowed_to? but throws
  # SecurityViolation exception leading to the denial page.
  def self.allowed_to_or_error?(verb, resource_type, tags = nil, org = nil, any_tags = false)
    u = User.current
    raise Errors::UserNotSet, "current user is not set" if u.nil? or not u.is_a? User
    unless u.allowed_to?(verb, resource_type, tags, org, any_tags)
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
        where("roles_users.user_id = ?", self.id).where("organization_id is NOT null")
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

  def self.cp_oauth_header
    raise Errors::UserNotSet, "unauthenticated to call a backend engine" if User.current.nil?
    User.current.cp_oauth_header
  end

  def pulp_oauth_header
    { 'pulp-user' => self.username }
  end

  def self.pulp_oauth_header
    raise Errors::UserNotSet, "unauthenticated to call a backend engine" if User.current.nil?
    { 'pulp-user' => User.current.username }
  end

  # is the current user consumer? (rhsm)
  def self.consumer?
    User.current.is_a? CpConsumerUser
  end

  def self.list_verbs global = false
    {
    :create => _("Administer Users"),
    :read => _("Read Users"),
    :update => _("Modify Users"),
    :delete => _("Delete Users")
    }.with_indifferent_access
  end

  def self.read_verbs
    [:read]
  end

  def self.no_tag_verbs
    [:create]
  end

  READ_PERM_VERBS = [:read,:update, :create,:delete]
  scope :readable, lambda {User.allowed_all_tags?(READ_PERM_VERBS, :users) ? where(:hidden=>false) :  where("0 = 1")}

  def self.creatable?
    User.allowed_to?([:create], :users, nil)
  end

  def self.any_readable?
    User.allowed_to?(READ_PERM_VERBS, :users, nil)
  end

  def readable?
    User.any_readable? && !hidden
  end

  def editable?
    User.allowed_to?([:create, :update], :users, nil) && !hidden
  end

  def deletable?
    self.id != User.current.id && User.allowed_to?([:delete], :users, nil)
  end

  def send_password_reset
    # generate a random password reset token that will be valid for only a configurable period of time
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!

    UserMailer.send_password_reset(self)
  end

  def has_default_env?
    #the own_role is used exclusively for storing a perm with a tag that tells the default env
    if !self.own_role
      return false
    else
      if Permission.find_all_by_role_id(self.own_role.id).empty?
        return false
      end
    end
    true
  end

  def default_environment
    sr = self.own_role
    perm = Permission.find_all_by_role_id(self.own_role.id)
    if sr && !perm.empty? && perm[0].tags
      return KTEnvironment.find(perm[0].tags[0].tag_id)
    end
    nil
  end

  def default_locale
    self.preferences[:user][:locale] rescue nil
  end

  def default_locale= locale
    self.preferences[:user] = {} unless self.preferences.has_key? :user
    self.preferences[:user][:locale] = locale
  end

  def subscriptions_match_system_preference
    self.preferences[:user][:subscriptions_match_system] rescue true
  end

  def subscriptions_match_system_preference= flag
    self.preferences[:user] = {} unless self.preferences.has_key? :user
    self.preferences[:user][:subscriptions_match_system] = flag
  end

  #method to delete the passed in org.  Due to the way delayed job is impelemented
  #  we must attached the job to a different instance or object, so we attach it to the current_user
  def destroy_organization_async org
    task = self.async(:organization=>org).destroy_organization(org.id)
    org.task_id = task.id
    org.save!
    task
  end

  def destroy_organization org_id
    org = Organization.unscoped{Organization.find(org_id)}
    name = org.name
    org.destroy
    message = _("Successfully removed organization '%s'.") % name
    notice message, { :synchronous_request => false, :request_type => "organization__delete"}
  rescue Exception=>e
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))
    error_text =  _("Failed to delete organization '%s'. Check notices for more details. ") % name
    details = e.message
    notice error_text, {:level => :error, :details => details, :synchronous_request => false, :request_type => "organization__delete"}
    raise
  end

  protected

  def can_be_deleted?
    query =  Permission.joins(:resource_type, :role).
                                joins("INNER JOIN roles_users ON roles_users.role_id = roles.id").
                                  where(:resource_types => {:name => :all}, :organization_id => nil)
    is_superadmin = query.where("roles_users.user_id" => id).count > 0
    return true unless is_superadmin
    more_than_one_supers = query.count > 1
    more_than_one_supers
  end

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


  def extended_index_attrs
    {:username_sort => username.downcase}
  end

  private

  # generate a random token, that is unique within the User table for the column provided
  def generate_token(column)
    begin
      self[column] = SecureRandom.hex(32)
    end while User.exists?(column => self[column])
  end

  def allowed_tags_query(verbs, resource_type,  org = nil, allowed_to_check = true)
    ResourceType.check resource_type, verbs
    verbs = [] if verbs.nil?
    verbs = [verbs] unless verbs.is_a? Array
    log_roles(verbs, resource_type, nil,org)
    org = Organization.find(org) if Numeric === org
    org_permissions = org_permissions_query(org, resource_type == :organizations)

    verbs = verbs.collect {|verb| action_to_verb(verb, resource_type)}
    clause = ""
    clause_params = {:all => "all",:true => true, :resource_type=>resource_type, :verbs=> verbs}

    unless resource_type == :organizations
      clause = %{permissions.resource_type_id = (select id from resource_types where resource_types.name = :resource_type) AND
      (permissions.all_verbs=:true OR verbs.verb in (:verbs))}.split.join(" ")

      org_permissions =  org_permissions.joins("left outer join permission_tags on permissions.id = permission_tags.permission_id")
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


  def log_roles verbs, resource_type, tags, org, any_tags = false
    if AppConfig.allow_roles_logging
      verbs_str = verbs ? verbs.join(','):"perform any verb"
      tags_str = "any tags"
      if tags
        tag_str = any_tags ? "any tag in #{tags.join(',')}" : "all the tags in #{tags.join(',')}"
      end

      org_str = org ? "organization #{org.name} (#{org.name})":" any organization"
      Rails.logger.debug "Checking if user #{username} is allowed to #{verbs_str} in #{resource_type.inspect} scoped for #{tags_str} in #{org_str}"
    end
  end

  def super_admin_check role
    if role.superadmin? && role.users.length == 1
      message = _("Cannot dissociate user '%s' from '%s' role. Need at least one user in the '%s' role.") % [username,
                                                                                                              role.name,
                                                                                                              role.name]
      errors[:base] << message
      raise  ActiveRecord::RecordInvalid, self
    end
  end

end
