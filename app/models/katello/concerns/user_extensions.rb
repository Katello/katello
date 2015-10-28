# rubocop:disable AccessModifierIndentation

module Katello
  module Concerns
    module UserExtensions
      extend ActiveSupport::Concern

      included do
        include Util::ThreadSession::UserModel

        has_many :task_statuses, :dependent => :destroy, :class_name => "Katello::TaskStatus"
        has_many :activation_keys, :dependent => :destroy, :class_name => "Katello::ActivationKey"

        def self.remote_user
          SETTINGS[:katello][:pulp][:default_login]
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

        def cp_oauth_header
          { 'cp-user' => self.login }
        end

        def allowed_organizations
          admin? ? Organization.all : self.organizations
        end
      end
    end
  end
end
