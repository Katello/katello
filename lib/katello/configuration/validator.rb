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

      def booleans?(*keys)
        keys.each { |key| boolean?(key) }
      end

      def boolean?(key)
        values?(key, [true, false])
      end

      def type?(key, *types)
        unless types.any? { |type| type === config[key] }
          fail error_format(key.to_sym, "has to be one of #{types.inspect} types")
        end
      end

      def values?(key, values, options = {})
        values << nil if options[:allow_nil]
        return true if values.include?(config[key])
        fail ArgumentError, error_format(key, "should be one of #{values.inspect}, but was #{config[key].inspect}")
      end

      def keys?(*keys)
        keys.each { |key| key? key }
      end

      def key?(key)
        unless config.key? key.to_sym
          fail error_format(key.to_sym, 'is required')
        end
      end

      private

      def error_format(key, message)
        key_path = (path + [key]).join('.')
        env      = environment ? "'#{environment}' environment" : 'early configuration'
        "Key: '#{key_path}' in #{env} #{message}"
      end

      def not_empty?(key)
        if config[key].nil? || config[key].empty?
          fail error_format(key.to_sym, "must not be empty")
        end
      end
    end
  end
end
