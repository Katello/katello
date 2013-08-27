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

# rubocop:disable CaseEquality, HashMethods
module Katello
  module Configuration

    # defines small dsl for validating configuration
    class Validator
      attr_reader :config, :environment, :path

      # @param [Node] config
      # @param [nil, Symbol] environment use nil for early or Symbol for environment
      # @yield block with validations
      def initialize(config, environment, path = [], &validations)
        @config, @environment, @path = config, environment, path
        instance_eval(&validations)
      end

      private

      def early?
        !environment
      end

      # validate sub key
      # @yield block with validations
      def validate(key, &block)
        Validator.new config[key] || Node.new, environment, (self.path + [key]), &block
      end

      def are_booleans(*keys)
        keys.each { |key| is_boolean key }
      end

      def is_boolean(key)
        has_values key, [true, false]
      end

      def is_type(key, *types)
        unless types.any? { |type| type === config[key] }
          raise error_format(key.to_sym, "has to be one of #{types.inspect} types")
        end
      end

      def has_values(key, values, options = {})
        values << nil if options[:allow_nil]
        return true if values.include?(config[key])
        raise ArgumentError, error_format(key, "should be one of #{values.inspect}, but was #{config[key].inspect}")
      end

      def has_keys(*keys)
        keys.each { |key| has_key key }
      end

      def has_key(key)
        unless config.has_key? key.to_sym
          raise error_format(key.to_sym, 'is required')
        end
      end

      private

      def error_format(key, message)
        key_path = (path + [key]).join('.')
        env      = environment ? "'#{environment}' environment" : 'early configuration'
        "Key: '#{key_path}' in #{env} #{message}"
      end

      def is_not_empty(key)
        if config[key].nil? || config[key].empty?
          raise error_format(key.to_sym, "must not be empty")
        end
      end
    end
  end
end
