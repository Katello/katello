# In several cases we want to break chain of responsibility in MVC a bit and provide
# a safe way to access current user (and maybe few more data items). Storing it as
# a global variable (or class member) is not thread-safe. Including ThreadSession::
# UserModel in models and ThreadSession::Controller in the application controller
# allows this without any concurrent issues.
#
# Idea taken from sentinent_user rails plugin.
#
# http://github.com/bokmann/sentient_user
# http://github.com/astrails/let_my_controller_go
# http://rails-bestpractices.com/posts/47-fetch-current-user-in-models
#

module Katello
  def self.pulp_server=(server)
    Thread.current[:pulp_server] = server
  end

  def self.pulp_server
    Thread.current[:pulp_server]
  end
end

module Katello
  module Util
    module ThreadSession
      # include this in the User model
      module UserModel
        # TODO: break up method
        # rubocop:disable MethodLength
        def self.included(base)
          base.class_eval do
            def self.current
              Thread.current[:user]
            end

            def self.current=(o)
              unless (o.nil? || o.is_a?(self) || o.class.name == 'RSpec::Mocks::Mock')
                fail(ArgumentError, "Unable to set current User, expected class '#{self}', got #{o.inspect}")
              end
              if o.is_a?(::User)
                debug = ["Setting current user thread-local variable to", o.firstname, o.lastname]
                Rails.logger.debug debug.join(" ")
              end
              Thread.current[:user] = o

              if SETTINGS[:katello][:use_cp] && o.respond_to?(:cp_oauth_header)
                self.cp_config(o.cp_oauth_header)
              end

              if SETTINGS[:katello][:use_pulp]
                self.pulp_config(User.remote_user)
              end
            end

            def self.pulp_config(user_remote_id, &_block)
              Katello.pulp_server = runcible_instance(SETTINGS[:katello][:pulp][:url], user_remote_id)
              yield if block_given?
            ensure
              Katello.pulp_server = nil if block_given?
            end

            def self.runcible_instance(pulp_url, user_remote_id)
              uri = URI.parse(pulp_url)

              Runcible::Instance.new(
                :url      => "#{uri.scheme}://#{uri.host.downcase}",
                :api_path => uri.path,
                :user     => user_remote_id,
                :timeout      => SETTINGS[:katello][:rest_client_timeout],
                :open_timeout => SETTINGS[:katello][:rest_client_timeout],
                :oauth    => {:oauth_secret => SETTINGS[:katello][:pulp][:oauth_secret],
                              :oauth_key    => SETTINGS[:katello][:pulp][:oauth_key] },
                :logging  => {:logger     => ::Foreman::Logging.logger('katello/pulp_rest'),
                              :exception  => true,
                              :info       => true,
                              :debug      => true }
              )
            end

            def self.cp_config(cp_oauth_header)
              Thread.current[:cp_oauth_header] = cp_oauth_header
              yield if block_given?
            ensure
              Thread.current[:cp_oauth_header] = nil if block_given?
            end
          end
        end
      end
    end
  end
end
