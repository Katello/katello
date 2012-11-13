#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'yaml'
require 'erb'


module Katello


  # Katello::Configuration module contains all necessary code for Katello configuration.
  # Configuration is not dependent on any gem which allows loading configuration very early (even before Rails).
  # Therefore this configuration can be used anywhere (Gemfile, boot scripts, etc.)
  #
  # Configuration access points are methods #config and #early_config, see method documentation.
  # There are shortcuts defined: `Katello.config` and `Katello.early_config`
  #
  # Configuration is represented with tree-like-structure defined with Configuration::Node. Node has minimal Hash-like
  # interface. Node is more strict than Hash. Differences:
  # * If undefined key is accessed an error NoKey is raised (keys with nil values has to be defined explicitly).
  # * Keys can be accessed by methods. `config.host` is equivalent to `config[:host]`
  # * All keys has to be Symbols, otherwise you get an ArgumentError
  #
  # AppConfig will work for now, but warning is printed to `$stderr`.
  #
  # Some examples
  #     # create by a Hash which is converted to Node instance
  #     irb> n = Katello::Configuration::Node.new 'a' => nil
  #     => #<Katello::Configuration::Node:0x10e27b618 @data={:a=>nil}>
  #
  #     # assign a value, also converted
  #     irb> n[:a] = {'a' => 12}
  #     => {:a=>12}
  #     irb> n
  #     => #<Katello::Configuration::Node:0x10e2cd2b0 @data={:a=>#<Katello::Configuration::Node:0x10e2bcb40 @data={:a=>12}>}>
  #
  #     # accessing a key
  #     irb> n['a']
  #     ArgumentError: "a" should be a Symbol
  #     irb> n[:a]
  #     => #<Katello::Configuration::Node:0x10e2bcb40 @data={:a=>12}>
  #     irb> n[:not]
  #     Katello::Configuration::Node::NoKey:  missing key 'not' in configuration
  #
  #     # sooports deep_merge and #to_hash
  #     irb> n.deep_merge!('a' => {:b => 34})
  #     => #<Katello::Configuration::Node:0x10e2cd2b0 @data={:a=>#<Katello::Configuration::Node:0x10e2a64d0 @data={:a=>12, :b=>34}>}>
  #     irb> n.to_hash
  #     => {:a=>{:a=>12, :b=>34}}
  module Configuration

    # Hash like container for configuration
    # @example allows access by method
    #   Config.new('a' => {:b => 2}).a.b # => 2
    # @example
    class Node
      class NoKey < StandardError
        def initialize(message = nil)
          #noinspection RubyArgCount
          super(" missing key '#{message}' in configuration")
        end
      end

      def initialize(data = { })
        @data = convert_hash data
      end

      include Enumerable

      def each(&block)
        @data.each &block
      end

      # get configuration for +key+
      # @param [Symbol] key
      # @raise [NoKye] when +key+ is missing
      def [](key)
        raise ArgumentError, "#{key.inspect} should be a Symbol" unless Symbol === key
        if has_key? key
          @data[key]
        else
          raise NoKey, key.to_s
        end
      end

      # converts +value+ to Config (see #convert)
      def []=(key, value)
        @data[key.to_sym] = convert value
      end

      def has_key?(key)
        @data.has_key? key
      end

      # allows access keys by method call
      # @raise [NoKye] when +key+ is missing
      def method_missing(method, *args, &block)
        if has_key?(method)
          self[method]
        else
          begin
            super
          rescue NoMethodError => e
            raise NoKey, method.to_s
          end
        end
      end

      # does not supports Hashes in Arrays
      def deep_merge!(hash_or_config)
        other_config = convert hash_or_config
        other_config.each do |key, other_value|
          value     = has_key?(key) && self[key]
          self[key] = Node === value && Node === other_value ? value.deep_merge!(other_value) : other_value
        end
        self
      end

      def to_hash
        @data.inject({ }) do |hash, (k, v)|
          hash.update k => (Node === v ? v.to_hash : v)
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
        raise ArgumentError, "#{hash.inspect} is not a Hash" unless Hash === hash

        hash.keys.each do |key|
          hash[(key.to_sym rescue key) || key] = convert hash.delete(key)
        end

        hash.keys.all? { |k| Symbol === k or raise ArgumentError, "keys must be Symbols, #{k.inspect} is not" }
        hash
      end
    end

    # processes configuration loading from config_files
    class Loader
      attr_reader :config_file_paths, :required_keys

      def initialize(options = { })
        @config_file_paths = options[:config_file_paths] || raise(ArgumentError)
        @required_keys     = options[:required_keys] || raise(ArgumentError)
      end

      # raw config data form katello.yml represented with Node
      def config_data
        @config_data ||= Node.new YAML::load(ERB.new(File.read(config_file_path)).result)
      end

      # access point for Katello configuration
      def config
        @config ||= load environment
      end

      # Configuration without environment applied, use in early stages (before Rails are loaded) like Gemfile
      # and other scripts
      def early_config
        @early_config ||= load
      end

      # @return [Hash{String => Hash}] database configurations
      def database_configs
        @database_configs ||= begin
          %w(production development test).inject({ }) do |hash, environment|
            common = config_data.common.database.to_hash
            hash.update environment => common.merge(config_data[environment.to_sym].database.to_hash).stringify_keys
          end
        end
      end

      private

      def load(environment = nil)
        Node.new.tap do |c|
          load_config_file c, environment
          load_env_variables c
          load_version c
          check_required! c
        end
      end

      def environment
        Rails.env.to_sym rescue raise 'Rails.env is not accessible, try to use #early_config instead'
      end

      def load_config_file(config, environment = nil)
        config.deep_merge! config_data[:common]
        config.deep_merge! config_data[environment] if environment
      end

      def load_env_variables(config)
        config[:url_prefix] = ENV['RAILS_RELATIVE_URL_ROOT'] || ''
        config[:headpin?]   = %w(/sam /headpin).include?(config.url_prefix)
        config[:katello?]   = !config.headpin?
        config[:app_name]   = config.headpin? ? 'Headpin' : 'Katello'

        config[:use_cp] = false if ENV['NO_CP']
        config[:use_pulp] = false if ENV['NO_PULP']
        config[:use_foreman] = false if ENV['NO_FOREMAN']

        log_levels = %w(debug info warn error fatal)

        if log_levels.include? ENV['KATELLO_LOGGING']
          config[:log_level] = ENV['KATELLO_LOGGING']
        elsif ENV['KATELLO_LOGGING']
          warn "unrecognized KATELLO_LOGGING: #{ENV['KATELLO_LOGGING']}"
        end

        if log_levels.include? ENV['KATELLO_LOGGING']
          config[:log_level_sql] = ENV['KATELLO_LOGGING_SQL']
        elsif ENV['KATELLO_LOGGING_SQL']
          warn "unrecognized KATELLO_LOGGING_SQL: #{ENV['KATELLO_LOGGING']}"
        end
      end

      def load_version(config)
        package = config.katello? ? 'katello-common' : 'katello-headpin'
        version = `rpm -q #{package} --queryformat '%{VERSION}-%{RELEASE}' 2>&1`
        if $? != 0
          hash    = `git rev-parse --short HEAD 2>/dev/null`
          version = $? == 0 ? "git hash (#{hash.chop})" : "Unknown"
        end

        config[:katello_version] = version
      end

      def check_required!(config)
        missing = required_keys.select { |key| not config.has_key? key.to_sym }
        missing.empty? or raise "configuration for #{missing.join(",")} is required"
      end

      def config_file_path
        @config_file_path ||= config_file_paths.find { |path| File.exist? path } or
            raise "no config file found, candidates: #{config_file_paths}"
      end
    end

    root      = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    TheLoader = Loader.new(
        :config_file_paths => %W(#{root}/config/katello.yml /etc/katello/katello.yml),
        :required_keys     =>
            %w( app_name candlepin notification debug_pulp_proxy debug_rest available_locales use_cp
                simple_search_tokens database debug_cp_proxy headpin? host ldap_roles cloud_forms use_pulp cdn_proxy
                use_ssl warden katello? url_prefix foreman search use_foreman password_reset_expiration
                redhat_repository_url port elastic_url rest_client_timeout elastic_index allow_roles_logging
                katello_version pulp tire_log log_level log_level_sql ))
  end


  def self.config
    Configuration::TheLoader.config
  end

  def self.early_config
    Configuration::TheLoader.early_config
  end

  def self.database_configs
    Configuration::TheLoader.database_configs
  end
end

path = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << path unless $LOAD_PATH.include? path
require 'app_config'
