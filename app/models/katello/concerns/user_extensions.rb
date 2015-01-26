# rubocop:disable AccessModifierIndentation
#
# Copyright 2014 Red Hat, Inc.
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
        include Glue if Katello.config.use_cp || Katello.config.use_pulp
        include ForemanTasks::Concerns::ActionSubject
        include ForemanTasks::Concerns::ActionTriggering

        def create_action
          sync_action!
          ::Actions::Katello::User::Create
        end

        def destroy_action
          sync_action!
          ::Actions::Katello::User::Destroy
        end

        include Util::ThreadSession::UserModel

        has_many :help_tips, :dependent => :destroy, :class_name => "Katello::HelpTip"
        has_many :user_notices, :dependent => :destroy, :class_name => "Katello::UserNotice"
        has_many :notices, :through => :user_notices, :class_name => "Katello::Notice"
        has_many :task_statuses, :dependent => :destroy, :class_name => "Katello::TaskStatus"
        has_many :search_favorites, :dependent => :destroy, :class_name => "Katello::SearchFavorite"
        has_many :search_histories, :dependent => :destroy, :class_name => "Katello::SearchHistory"
        has_many :activation_keys, :dependent => :destroy, :class_name => "Katello::ActivationKey"
        serialize :preferences, Hash

        after_validation :setup_remote_id
        before_save :setup_preferences

        def setup_preferences
          self.preferences = Hash.new unless self.preferences
        end

        def preferences_hash
          self.preferences.is_a?(Hash) ? self.preferences : self.preferences.unserialized_value
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

        def disable_helptip(key)
          return unless self.helptips_enabled? #don't update helptips if user has it disabled
          return unless Katello::HelpTip.where(:key => key, :user_id => self.id).empty?
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
          return unless self.helptips_enabled? #don't update helptips if user has it disabled
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

        def cp_oauth_header
          { 'cp-user' => self.login }
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
            return org if self.organizations.include?(org)
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

        def allowed_organizations
          (admin? || anonymous_admin) ? Organization.all : self.organizations
        end

        private

        # generate a random token, that is unique within the User table for the column provided
        def generate_token(column)
          loop do
            self[column] = SecureRandom.hex(32)
            break unless User.exists?(column => self[column])
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
          if User.current.object_id == self.object_id
            # The case when the first user is being created.
            Katello.config.pulp.default_login
          elsif self.login.ascii_only?
            "#{Util::Model.labelize(self.login)}-#{SecureRandom.hex(4)}"
          else
            Util::Model.uuid
          end
        end
      end
    end
  end
end
