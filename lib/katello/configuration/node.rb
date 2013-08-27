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

# rubocop:disable HashMethods
module Katello
  module Configuration

    # Hash like container for configuration
    # @example allows access by method
    #     Node.new('a' => {:b => 2}).a.b # => 2
    class Node
      class NoKey < StandardError
        def initialize(message = nil)
          #noinspection RubyArgCount
          super(" missing key '#{message}' in configuration")
        end
      end

      def initialize(data = {})
        @data = convert_hash data
      end

      include Enumerable

      def each(&block)
        @data.each(&block)
      end

      # get configuration for `key`
      # @param [Symbol] key
      # @raise [NoKye] when key is missing
      def [](key)
        raise ArgumentError, "#{key.inspect} should be a Symbol" unless key.is_a?(Symbol)
        if has_key? key
          @data[key].is_a?(Proc) ? @data[key].call : @data[key]
        else
          raise NoKey, key.to_s
        end
      end

      # converts `value` to Config
      # @see #convert
      def []=(key, value)
        @data[key.to_sym] = convert value
      end

      def has_key?(key)
        @data.has_key? key
      end

      # @example does node contain value at `node[:key1][:key2]`
      #    node.present? :key1, :key2
      def present?(*keys)
        key, rest = keys.first, keys[1..-1]
        raise ArgumentError, 'supply at least one key' unless key
        has_key?(key) && self[key] && if rest.empty?
                                        true
                                      elsif self[key].is_a?(Node)
                                        self[key].present?(*rest)
                                      else
                                        false
                                      end
      end

      # allows access keys by method call
      # @raise [NoKye] when `key` is missing
      def method_missing(method, *args, &block)
        if has_key?(method)
          self[method]
        else
          begin
            super
          rescue NoMethodError
            raise NoKey, method.to_s
          end
        end
      end

      # respond to implementation according to method missing
      def respond_to?(symbol, include_private = false)
        has_key?(symbol) || super
      end


      # does not supports Hashes in Arrays
      def deep_merge!(hash_or_config)
        return self if hash_or_config.nil?
        other_config = convert hash_or_config
        other_config.each do |key, other_value|
          value     = has_key?(key) && self[key]
          self[key] = if value.is_a?(Node) && other_value.is_a?(Node)
                        value.deep_merge!(other_value)
                      elsif value.is_a?(Node) && other_value.nil?
                        self[key]
                      else
                        other_value
                      end
        end
        self
      end

      def to_hash
        @data.inject({}) do |hash, (k, v)|
          hash.update k => (v.is_a?(Node) ? v.to_hash : v)
        end
      end

      private

      # converts config like deep structure by finding Hashes deeply and converting them to Config
      def convert(obj)
        case obj
        when Node
          obj
        when Hash
          Node.new convert_hash obj
        when Array
          obj.map { |o| convert o }
        else
          obj
        end
      end

      # converts Hash by symbolizing keys and allowing only symbols as keys
      def convert_hash(hash)
        raise ArgumentError, "#{hash.inspect} is not a Hash" unless hash.is_a?(Hash)

        hash.keys.each do |key|
          hash[(key.to_sym rescue key) || key] = convert hash.delete(key)
        end

        hash.keys.all? do |k|
          raise ArgumentError, "keys must be Symbols, #{k.inspect} is not" unless k.is_a?(Symbol)
        end
        hash
      end
    end
  end
end
