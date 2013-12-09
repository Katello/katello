# rubocop:disable AccessModifierIndentation
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

require 'util/password'

module Katello
  module Concerns
    module UserExtensions
      extend ActiveSupport::Concern

      included do

        include Glue::Pulp::User if Katello.config.use_pulp
        include Glue::ElasticSearch::User if Katello.config.use_elasticsearch
        include Glue if Katello.config.use_cp || Katello.config.use_pulp

        include Glue::Event

        def create_event
          Headpin::Actions::UserCreate
        end

        def destroy_event
          Headpin::Actions::UserDestroy
        end

        include AsyncOrchestration

        include Ext::IndexedModel

        include AsyncOrchestration
        include Katello::Authorization::User
        include Authorization::Enforcement
        include Util::ThreadSession::UserModel

        scope :hidden, where(:hidden => true)
        scope :visible, where(:hidden => false)

        # RAILS3458: THIS CHECK MUST BE THE FIRST before_destroy AND
        # PROCEED DEPENDENT ASSOCIATIONS tinyurl.com/rails3458
        before_destroy :not_last_super_user?, :destroy_own_role

        has_many :roles_users, :dependent => :destroy, :class_name => Katello::RolesUser
        has_many :katello_roles, :through => :roles_users, :before_remove => :super_admin_check, :uniq => true, :extend => RolesPermissions::UserOwnRole, :source => :role
        has_many :help_tips, :dependent => :destroy, :class_name => "Katello::HelpTip"
        has_many :user_notices, :dependent => :destroy, :class_name => "Katello::UserNotice"
        has_many :notices, :through => :user_notices, :class_name => "Katello::Notice"
        has_many :task_statuses, :dependent => :destroy, :class_name => "Katello::TaskStatus"
        has_many :search_favorites, :dependent => :destroy, :class_name => "Katello::SearchFavorite"
        has_many :search_histories, :dependent => :destroy, :class_name => "Katello::SearchHistory"
        has_many :activation_keys, :dependent => :destroy, :class_name => "Katello::ActivationKey"
        has_many :changeset_users, :dependent => :destroy, :class_name => "Katello::ChangesetUser"
        belongs_to :default_environment, :class_name => "Katello::KTEnvironment", :inverse_of => :users
        serialize :preferences, Hash

        validates :default_locale, :inclusion => {:in => Katello.config.available_locales, :allow_nil => true, :message => _("must be one of %s") % Katello.config.available_locales.join(', ')}
        validates_with Validators::OwnRolePresenceValidator, :attributes => :katello_roles

        before_validation :create_own_role
        after_validation :setup_remote_id
        before_save   :hash_password, :setup_preferences
        after_save :create_or_update_default_system_registration_permission

        # hash the password before creating or updateing the record
        def hash_password
          if Katello.config.warden != 'ldap'
            self.password = Password.update(self.password) if self.password && self.password.length != 192
          end
        end

        def setup_preferences
          self.preferences = Hash.new unless self.preferences
        end

        def preferences_hash
          self.preferences.is_a?(Hash) ? self.preferences : self.preferences.unserialized_value
        end

        def not_last_super_user?
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

        def ldap_mode?
          !not_ldap_mode?
        end

        def own_role
          katello_roles.find_own_role
        end

        def self.authenticate!(login, password)
          u = User.where({ :login => login }).first
          # check if user exists
          return nil unless u
          # check if not disabled
          return nil if u.disabled
          # check if we have password (can be set to nil for users from LDAP when you switch to DB)
          return nil if u.password.nil?
          # check if hash is valid
          return nil unless Password.check(password, u.password)
          u
        end

        # if the user authenticates with LDAP, log them in
        def self.authenticate_using_ldap!(login, password)
          if Ldap.valid_ldap_authentication? login, password
            User.where(:login => login).first || create_ldap_user!(login)
          else
            nil
          end
        end

        # an ldap user still needs a katello model
        def self.create_ldap_user!(login)
          # Some parts of user creation require a current user, but this method
          # will never be called in that way
          User.current ||= User.first
          # user gets a dummy password and email
          u = User.create!(:login => login)
          User.current = u
          u
        end

        def self.cp_oauth_header
          fail Errors::UserNotSet, "unauthenticated to call a backend engine" if Thread.current[:cp_oauth_header].nil?
          Thread.current[:cp_oauth_header]
        end

        def cp_oauth_header
          { 'cp-user' => self.username }
        end

        # is the current user consumer? (rhsm)
        def self.consumer?
          User.current.is_a? CpConsumerUser
        end

        def allowed_organizations
          #test for all orgs
          perms = Permission.joins(:role).joins("INNER JOIN #{Katello::RolesUser.table_name} ON #{Katello::RolesUser.table_name}.role_id = #{Katello::Role.table_name}.id").
              where("#{Katello::RolesUser.table_name}.user_id = ?", self.id).where(:organization_id => nil).count
          return Organization.without_deleting.all if perms > 0

          Organization.without_deleting.joins(:permissions => {:role => :users}).where(:users => {:id => self.id}).uniq
        end

        def disable_helptip(key)
          return if !self.helptips_enabled? #don't update helptips if user has it disabled
          return if !Katello::HelpTip.where(:key => key, :user_id => self.id).empty?
          help      = Katello::HelpTip.new
          help.key  = key
          help.user = self
          help.save
        end

        #Remove up to 5 un-viewed notices
        def pop_notices(organization = nil, count = 5)
          notices = Notice.for_user(self).for_org(organization).unread.limit(count == :all ? nil : count)
          notices.each { |notice| notice.user_notices.each(&:read!) }

          notices = notices.map do |notice|
            {:text => notice.text, :level => notice.level, :request_type => notice.request_type}
          end
          return notices
        end

        def enable_helptip(key)
          return if !self.helptips_enabled? #don't update helptips if user has it disabled
          help = Katello::HelpTip.where(:key => key, :user_id => self.id).first
          return if help.nil?
          help.destroy
        end

        def clear_helptips
          Katello::HelpTip.destroy_all(:user_id => self.id)
        end

        def helptip_enabled?(key)
          return self.helptips_enabled && Katello::HelpTip.where(:key => key, :user_id => self.id).first.nil?
        end

        def defined_roles
          self.katello_roles - [self.own_role]
        end

        def defined_role_ids
          self.katello_role_ids - [self.own_role.id]
        end

        def cp_oauth_header
          { 'cp-user' => self.login }
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
          return if default_environment.nil? || !default_environment.changed?
          own_role.create_or_update_default_system_registration_permission(default_environment.organization, default_environment)
        end

        def default_locale
          self.preferences_hash[:user][:locale] rescue nil
        end

        def default_locale=(locale)
          self.preferences_hash[:user] = { } unless self.preferences_hash.key? :user
          self.preferences_hash[:user][:locale] = locale
        end

        def legacy_mode
          self.preferences_hash[:user][:legacy_mode] rescue nil
        end

        def legacy_mode=(use_legacy_mode)
          self.preferences_hash[:user] = { } unless self.preferences_hash.key? :user
          self.preferences_hash[:user][:legacy_mode] = use_legacy_mode.to_bool
        end

        def default_org
          org_id = self.preferences_hash[:user][:default_org] rescue nil
          if org_id && !org_id.nil? && org_id != "nil"
            org = Organization.find_by_id(org_id)
            return org if allowed_organizations.include?(org)
          else
            return nil
          end
        end

        #set the default org if it's an actual org_id
        def default_org=(org_id)
          self.preferences_hash[:user] = { } unless self.preferences_hash.key? :user
          if !org_id.nil? && org_id != "nil"
            organization = Organization.find_by_id(org_id)
            self.preferences_hash[:user][:default_org] = organization.id
          else
            self.preferences_hash[:user][:default_org] = nil
          end
        end

        def subscriptions_match_system_preference
          self.preferences_hash[:user][:subscriptions_match_system] rescue false
        end

        def subscriptions_match_system_preference=(flag)
          self.preferences_hash[:user] = { } unless self.preferences_hash.key? :user
          self.preferences_hash[:user][:subscriptions_match_system] = flag
        end

        def subscriptions_match_installed_preference
          self.preferences_hash[:user][:subscriptions_match_installed] rescue false
        end

        def subscriptions_match_installed_preference=(flag)
          self.preferences_hash[:user] = { } unless self.preferences_hash.key? :user
          self.preferences_hash[:user][:subscriptions_match_installed] = flag
        end

        def subscriptions_no_overlap_preference
          self.preferences_hash[:user][:subscriptions_no_overlap] rescue false
        end

        def subscriptions_no_overlap_preference=(flag)
          self.preferences_hash[:user] = { } unless self.preferences_hash.key? :user
          self.preferences_hash[:user][:subscriptions_no_overlap] = flag
        end

        def as_json(options)
          super(options).merge 'default_organization' => default_environment.try(:organization).try(:name),
                               'default_environment'  => default_environment.try(:name)
        end

        def has_superadmin_role?
          katello_roles.any? { |r| r.superadmin? }
        end

        # verify the user is in the groups we are think they are in
        # if not, reset them
        def verify_ldap_roles
          # get list of ldap_groups bound to roles the user is in
          ldap_groups = LdapGroupRole.
              joins(:role => :roles_users).
              where(:katello_roles_users => { :ldap => true, :user_id => id }).
              select(:ldap_group).
              uniq.
              map(&:ldap_group)

          # make sure the user is still in those groups
          # this operation is inexpensive compared to getting a new group list
          if !Ldap.is_in_groups(self.login, ldap_groups)
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
          clear_existing_ldap_roles!
          # load groups from ldap
          groups = Ldap.ldap_groups(self.login)
          groups.each do |group|
            # find corresponding
            group_roles = LdapGroupRole.find_all_by_ldap_group(group)
            group_roles.each do |group_role|
              if group_role && !self.roles.reload.include?(group_role.role)
                self.roles_users << RolesUser.new(:role => group_role.role, :user => self, :ldap => true)
              end
            end
          end
          self.save
        end

        def clear_existing_ldap_roles!
          self.katello_roles = self.roles_users.select { |r| !r.ldap }.map { |r| r.role }
          self.save!
        end

        def ldap_roles
          roles_users.select { |r| r.ldap }.map { |r| r.role }
        end

        # returns the set of users who have kt_environment_id's environment set as their default
        def self.with_default_environment(kt_environment_id)
          where(:default_environment_id => kt_environment_id)
        end

        def create_or_update_search_history(path, search_params)
          unless search_params.nil? || search_params.blank? || empty_display_attributes?(search_params)
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
          query         = Katello::Permission.joins(:resource_type, :role).
              joins("INNER JOIN #{Katello::RolesUser.table_name} ON #{Katello::RolesUser.table_name}.role_id = #{Katello::Role.table_name}.id").
              where(:katello_resource_types => { :name => :all }, :organization_id => nil)
          is_superadmin = query.where("#{Katello::RolesUser.table_name}.user_id" => id).count > 0
          return true unless is_superadmin
          more_than_one_supers = query.count > 1
          more_than_one_supers
        end

        private

        # generate a random token, that is unique within the User table for the column provided
        def generate_token(column)
          loop do
            self[column] = SecureRandom.hex(32)
            break unless User.exists?(column => self[column])
          end
        end

        def log_roles(verbs, resource_type, tags, org, any_tags = false)
          verbs_str = verbs ? verbs.join(',') : "perform any verb"
          tags_str  = "any tags"
          if tags
            tags_str = any_tags ? "any tag in #{tags.join(',')}" : "all the tags in #{tags.join(',')}"
          end

          org_str = org ? "organization #{org.name} (#{org.name})" : " any organization"
          logger.debug "Checking if user #{login} is allowed to #{verbs_str} in #{resource_type.inspect} " +
            "scoped for #{tags_str} in #{org_str}"
        end

        def create_own_role
          return unless new_record?
          katello_roles.find_or_create_own_role(self)
        end

        def destroy_own_role
          katello_roles.destroy_own_role
        end

        def super_admin_check(role)
          if role.superadmin? && role.users.length == 1
            message = _("Cannot dissociate user '%{login}' from '%{role}' role. Need at least one user in the '%{role}' role.") % {:login => login, :role => role.name}
            errors[:base] << message
            fail ActiveRecord::RecordInvalid, self
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
          if self.login.ascii_only?
            "#{Util::Model.labelize(self.login)}-#{SecureRandom.hex(4)}"
          else
            Util::Model.uuid
          end
        end

        def logger
          ::Logging.logger['roles']
        end

      end
    end
  end
end
