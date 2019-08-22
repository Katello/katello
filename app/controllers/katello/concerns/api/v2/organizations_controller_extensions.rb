module Katello
  module Concerns
    module Api::V2::OrganizationsControllerExtensions
      extend ActiveSupport::Concern

      included do
        rescue_from ::ForemanTasks::Lock::LockConflict do |error|
          ::Foreman::Logging.exception("Action failed", error)
          render_error 'standard_error', :status => :unprocessable_entity, :locals => { :exception => error }
        end
      end
    end
  end
end
