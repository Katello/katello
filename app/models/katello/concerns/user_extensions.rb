module Katello
  module Concerns
    module UserExtensions
      extend ActiveSupport::Concern

      included do
        has_many :task_statuses, :dependent => :destroy, :class_name => "Katello::TaskStatus"
        has_many :activation_keys, :dependent => :nullify, :class_name => "Katello::ActivationKey"

        def self.remote_user
          SETTINGS[:katello][:pulp][:default_login]
        end

        def self.cp_oauth_header
          { 'cp-user' => User.anonymous_admin.login }
        end

        def self.cp_config(cp_oauth_header)
          Thread.current[:cp_oauth_header] = cp_oauth_header
          yield if block_given?
        ensure
          Thread.current[:cp_oauth_header] = nil if block_given?
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
