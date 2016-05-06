module Katello
  module Services
    module PuppetClassImporterExtensions
      extend ActiveSupport::Concern

      included do
        def update_environment
          change_types = %w(new obsolete updated)
          changed = self.changes

          change_types.each do |kind|
            changed[kind].slice!(@environment) unless changed[kind].empty?
          end

          #prevent the puppet environment from being deleted, by removing special '_destroy_' String
          if changed['obsolete'][@environment]
            changed['obsolete'][@environment] =
              changed['obsolete'][@environment].select { |klass| klass != '_destroy_' }
          end

          # PuppetClassImporter expects [kind][env] to be in json format
          change_types.each do |kind|
            unless (envs = changed[kind]).empty?
              envs.keys.sort.each do |env|
                changed[kind][env] = changed[kind][env].to_json
              end
            end
          end

          self.obsolete_and_new(changed)
        end
      end
    end
  end
end
