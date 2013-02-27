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
require 'util/model_util'

class User < ActiveRecord::Base
  include Glue::Pulp::User if Katello.config.use_pulp
  include Glue::Foreman::User if Katello.config.use_foreman
  include Glue::ElasticSearch::User if Katello.config.use_elasticsearch
  include Glue if Katello.config.use_cp || Katello.config.use_foreman || Katello.config.use_pulp
  include AsyncOrchestration
  include Ext::IndexedModel

  include AsyncOrchestration
  include Authorization::User
  include Authorization::Enforcement
  include Katello::ThreadSession::UserModel

  acts_as_reportable

  scope :hidden, where(:hidden => true)
  scope :visible, where(:hidden => false)

  has_many :roles_users
  has_many :roles, :through => :roles_users, :before_remove => :super_admin_check, :uniq => true, :extend => RolesPermissions::UserOwnRole
  validates_with Validators::OwnRolePresenceValidator, :attributes => :roles
  has_many :help_tips
  has_many :user_notices
  has_many :notices, :through => :user_notices
  has_many :search_favorites, :dependent => :destroy
  has_many :search_histories, :dependent => :destroy
  belongs_to :default_environment, :class_name => "KTEnvironment"
  serialize :preferences, HashWithIndifferentAccess

  validates :username, :uniqueness => true, :presence => true
  validates_with Validators::UsernameValidator, :attributes => :username
  validates_with Validators::NoTrailingSpaceValidator, :attributes => :username

  validates :email, :presence => true, :if => :not_ldap_mode?
  validates :default_locale, :inclusion => {:in => Katello.config.available_locales, :allow_nil => true, :message => _("must be one of %s") % Katello.config.available_locales.join(', ')}

  # validate the password length before hashing
  validates_each :password do |model, attr, value|
    if Katello.config.warden != 'ldap'
      if model.password_changed?
        model.errors.add(attr, _("must be at least 5 characters.")) if value.length < 5
      end
    end
  end

  before_validation :create_own_role
  after_validation :setup_remote_id
  before_save   :hash_password, :setup_preferences
  after_save :create_or_update_default_system_registration_permission
  # THIS CHECK MUST BE THE FIRST before_destroy
  before_destroy :is_last_super_user?, :destroy_own_role

  # hash the password before creating or updateing the record
  def hash_password
    if Katello.config.warden != 'ldap'
      self.password = Password::update(self.password) if self.password.length != 192
    end
  end

  def setup_preferences
    self.preferences = HashWithIndifferentAccess.new unless self.preferences
  end

  def is_last_super_user?
    if !User.current.nil?
      if self.id == User.current.id
        self.errors.add(:base, _("Cannot delete currently logged user"))
        return false
      end
    end

    unless self.can_be_deleted?
      self.errors.add(:base, "cannot delete last admin user")
      return false
    end
    return true
  end


  def not_ldap_mode?
    return Katello.config.warden != 'ldap'
  end

  def own_role
    roles.find_own_role
  end

  def self.authenticate!(username, password)
    u = User.where({ :username => username }).first
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
      User.where({ :username => username }).first || create_ldap_user!(username)
    else
      nil
    end
  end

  # an ldap user still needs a katello model
  def self.create_ldap_user!(username)
    # Some parts of user creation require a current user, but this method
    # will never be called in that way
    User.current ||= User.first
    # user gets a dummy password and email
    u = User.create!(:username => username)
    User.current = u
    u
  end

  def self.cp_oauth_header
    raise Errors::UserNotSet, "unauthenticated to call a backend engine" if User.current.nil?
    User.current.cp_oauth_header
  end

  # is the current user consumer? (rhsm)
  def self.consumer?
    User.current.is_a? CpConsumerUser
  end

  def allowed_organizations
    #test for all orgs
    perms = Permission.joins(:role).joins("INNER JOIN roles_users ON roles_users.role_id = roles.id").
        where("roles_users.user_id = ?", self.id).where(:organization_id => nil).count()
    return Organization.without_deleting.all if perms > 0

    Organization.without_deleting.joins(:permissions => {:role => :users}).where(:users => {:id => self.id}).uniq
  end

  def disable_helptip(key)
    return if !self.helptips_enabled? #don't update helptips if user has it disabled
    return if not HelpTip.where(:key => key, :user_id => self.id).empty?
    help      = HelpTip.new
    help.key  = key
    help.user = self
    help.save
  end

  #Remove up to 5 un-viewed notices
  def pop_notices(organization = nil, count = 5)
    notices = Notice.for_user(self).for_org(organization).unread.limit(count == :all ? nil : count)
    notices.each { |notice| notice.user_notices.each(&:read!) }

    return notices.map do |notice|
      { :text => notice.text, :level => notice.level, :request_type => notice.request_type }
    end
  end

  def enable_helptip(key)
    return if !self.helptips_enabled? #don't update helptips if user has it disabled
    help = HelpTip.where(:key => key, :user_id => self.id).first
    return if help.nil?
    help.destroy
  end

  def clear_helptips
    HelpTip.destroy_all(:user_id => self.id)
  end

  def helptip_enabled?(key)
    return self.helptips_enabled && HelpTip.where(:key => key, :user_id => self.id).first.nil?
  end

  def defined_roles
    self.roles - [self.own_role]
  end

  def defined_role_ids
    self.role_ids - [self.own_role.id]
  end

  def cp_oauth_header
    { 'cp-user' => self.username }
  end

  def send_password_reset
    # generate a random password reset token that will be valid for only a configurable period of time
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!

    UserMailer.send_password_reset(self)
  end

  def has_default_environment?
    !default_environment.nil?
  end

  def create_or_update_default_system_registration_permission
    return if default_environment.nil? or (not default_environment.changed?)
    own_role.create_or_update_default_system_registration_permission(default_environment.organization, default_environment)
  end

  def default_locale
    self.preferences[:user][:locale] rescue nil
  end

  def default_locale=(locale)
    self.preferences[:user] = { } unless self.preferences.has_key? :user
    self.preferences[:user][:locale] = locale
  end

  def default_org
    org_id = self.preferences[:user][:default_org] rescue nil
    if org_id && !org_id.nil? && org_id != "nil"
      org = Organization.find_by_id(org_id)
      return org if allowed_organizations.include?(org)
    else
      return nil
    end
  end

  #set the default org if it's an actual org_id
  def default_org=(org_id)
    self.preferences[:user] = { } unless self.preferences.has_key? :user
    if !org_id.nil? && org_id != "nil"
      organization = Organization.find_by_id(org_id)
      self.preferences[:user][:default_org] = organization.id
    else
      self.preferences[:user][:default_org] = nil
    end
  end

  def subscriptions_match_system_preference
    self.preferences[:user][:subscriptions_match_system] rescue false
  end

  def subscriptions_match_system_preference=(flag)
    self.preferences[:user] = { } unless self.preferences.has_key? :user
    self.preferences[:user][:subscriptions_match_system] = flag
  end

  def subscriptions_match_installed_preference
    self.preferences[:user][:subscriptions_match_installed] rescue false
  end

  def subscriptions_match_installed_preference=(flag)
    self.preferences[:user] = { } unless self.preferences.has_key? :user
    self.preferences[:user][:subscriptions_match_installed] = flag
  end

  def subscriptions_no_overlap_preference
    self.preferences[:user][:subscriptions_no_overlap] rescue false
  end

  def subscriptions_no_overlap_preference=(flag)
    self.preferences[:user] = { } unless self.preferences.has_key? :user
    self.preferences[:user][:subscriptions_no_overlap] = flag
  end

  def as_json(options)
    super(options).merge 'default_organization' => default_environment.try(:organization).try(:name),
                         'default_environment'  => default_environment.try(:name)
  end

  def has_superadmin_role?
    roles.any? { |r| r.superadmin? }
  end

  # verify the user is in the groups we are think they are in
  # if not, reset them
  def verify_ldap_roles
    # get list of ldap_groups bound to roles the user is in
    ldap_groups = LdapGroupRole.
        joins(:role => :roles_users).
        where(:roles_users => { :ldap => true, :user_id => id }).
        select(:ldap_group).
        uniq.
        map(&:ldap_group)

    # make sure the user is still in those groups
    # this operation is inexpensive compared to getting a new group list
    if !Ldap.is_in_groups(self.username, ldap_groups)
      # if user is not in these groups, flush their roles
      # this is expensive
      set_ldap_roles
    else
      return true
    end
  end

  # flush existing ldap roles + load & save new ones
  def set_ldap_roles
    # first, delete existing ldap roles
    clear_existing_ldap_roles
    # load groups from ldap
    groups = Ldap.ldap_groups(self.username)
    groups.each do |group|
      # find corresponding
      group_roles = LdapGroupRole.find_all_by_ldap_group(group)
      group_roles.each do |group_role|
        if group_role
          role_user = RolesUser.new(:role => group_role.role, :user => self, :ldap => true)
          self.roles_users << role_user unless self.roles.include?(group_role.role)
        end
      end
    end
    self.save
  end

  def clear_existing_ldap_roles
    self.roles = self.roles_users.select { |r| !r.ldap }.map { |r| r.role }
  end

  def ldap_roles
    roles_users.select { |r| r.ldap }.map { |r| r.role }
  end

  # returns the set of users who have kt_environment_id's environment set as their default
  def self.with_default_environment(kt_environment_id)
    where(:default_environment_id => kt_environment_id)
  end

  def create_or_update_search_history(path, search_params)
    unless search_params.nil? or search_params.blank? or empty_display_attributes?(search_params)
      if history = search_histories.find_or_create_by_path_and_params(path, search_params)
        history.update_attributes(:updated_at => Time.now)
      end
    end
  end

  def empty_display_attributes?(a_search_string)
    tokens = a_search_string.strip.split(/\s/)
    return false if tokens.size > 1

    return false unless tokens.first.end_with?(':')
    true
  end

  protected

  def can_be_deleted?
    query         = Permission.joins(:resource_type, :role).
        joins("INNER JOIN roles_users ON roles_users.role_id = roles.id").
        where(:resource_types => { :name => :all }, :organization_id => nil)
    is_superadmin = query.where("roles_users.user_id" => id).count > 0
    return true unless is_superadmin
    more_than_one_supers = query.count > 1
    more_than_one_supers
  end

  private

  # generate a random token, that is unique within the User table for the column provided
  def generate_token(column)
    begin
      self[column] = SecureRandom.hex(32)
    end while User.exists?(column => self[column])
  end

  def log_roles verbs, resource_type, tags, org, any_tags = false
    if Katello.config.allow_roles_logging
      verbs_str = verbs ? verbs.join(',') :"perform any verb"
      tags_str  = "any tags"
      if tags
        tag_str = any_tags ? "any tag in #{tags.join(',')}" : "all the tags in #{tags.join(',')}"
      end

      org_str = org ? "organization #{org.name} (#{org.name})" :" any organization"
      Rails.logger.debug "Checking if user #{username} is allowed to #{verbs_str} in #{resource_type.inspect} " +
                             "scoped for #{tags_str} in #{org_str}"
    end
  end

  def create_own_role
    return unless new_record?
    roles.find_or_create_own_role(self)
  end

  def destroy_own_role
    roles.destroy_own_role
  end

  def super_admin_check role
    if role.superadmin? && role.users.length == 1
      message = _("Cannot dissociate user '%{username}' from '%{role}' role. Need at least one user in the '%{role}' role.") % {:username => username, :role => role.name}
      errors[:base] << message
      raise ActiveRecord::RecordInvalid, self
    end
  end

  def setup_remote_id
    #if validation failed, don't setup
    return false unless self.errors.empty?
    if  self.remote_id.nil?
      self.remote_id = generate_remote_id
    end
    return true
  end

  def generate_remote_id
    if self.username.ascii_only?
      "#{Katello::ModelUtils::labelize(self.username)}-#{SecureRandom.hex(4)}"
    else
      Katello::ModelUtils::uuid
    end
  end

end
