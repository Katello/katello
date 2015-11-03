require 'katello/util/thread_session'

if SETTINGS[:katello] && SETTINGS[:katello][:use_pulp]

  # override Runcible's default configuration error message
  module Runcible
    class ConfigurationUndefinedError
      def self.message
        "Runcible configuration not defined. Is User.current set?"
      end
    end
  end

end
