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

require 'yaml'
require 'erb'

module Katello
  module Configuration

    # processes configuration loading from config_files
    class Loader
      attr_reader :config_file_paths,
                  :validation,
                  :default_config_file_path,
                  :config_post_process,
                  :load_yml_post_process

      # @param [Hash] options
      # @option options [Array<String>] :config_file_paths paths to look for configuration files (first one is used)
      # @option options [String] :default_config_file_path path to file with default configuration values
      # @option options [Proc] :validation validating the configuration
      # @option options [Proc] :config_post_process called on each full configuration after it's constructed
      #   e.g. to add config[:katello?] = lambda { config.app_mode == 'katello' }
      # @option options [Proc] :load_yml_post_process called on each configuration loaded from yaml file
      #   e.g. to decrypt db password
      def initialize(options = {})
        @config_file_paths        = options[:config_file_paths] || raise(ArgumentError)
        @default_config_file_path = options[:default_config_file_path] || raise(ArgumentError)
        @validation               = options[:validation] || raise(ArgumentError)
        @config_post_process      = options[:config_post_process]
        @load_yml_post_process    = options[:load_yml_post_process]
      end

      # raw config data from katello.yml represented with Node
      def config_data
        @config_data ||= Node.new.tap do |c|
          c.deep_merge! default_config_data
          c.deep_merge! load_yml_file(config_file_path)
        end
      end

      # raw config data from katello_defaults.yml represented with Node
      def default_config_data
        @default_config_data ||= load_yml_file default_config_file_path
      end

      # access point for Katello configuration
      def config
        @config ||= load(environment)
      end

      # Configuration without environment applied, use in early stages (before Rails are loaded)
      # like Gemfile and other scripts
      def early_config
        @early_config ||= load
      end

      # @return [Hash{String => Hash}] database configurations
      def database_configs
        @database_configs ||= begin
          %w(production development test).inject({}) do |hash, environment|
            common = config_data.common.database.to_hash
            if config_data.present?(environment.to_sym, :database)
              hash.update(
                  environment =>
                      common.merge(config_data[environment.to_sym].database.to_hash).stringify_keys)
            else
              hash
            end
          end
        end
      end

      private

      def load(environment = nil)
        Node.new.tap do |c|
          load_config_file c, environment
          config_post_process.call c, environment  if config_post_process
          validate c, environment
        end
      end

      def load_yml_file(file_path)
        raw_parsed_yml  = YAML::load(ERB.new(File.read(file_path)).result(Object.new.send(:binding)))
        hash_parsed_yml = case raw_parsed_yml
                          when Hash
                            raw_parsed_yml
                          when nil, false, ''
                            {}
                          else
                            raise "malformed yml file '#{file_path}'"
                          end

        Node.new(hash_parsed_yml).tap do |config|
          load_yml_post_process.call(config) if load_yml_post_process
        end
      end

      def environment
        Rails.env.to_sym rescue raise 'Rails.env is not accessible, try to use #early_config instead'
      end

      def load_config_file(config, environment = nil)
        config.deep_merge! config_data[:common]
        config.deep_merge! config_data[environment] if environment
      end

      def validate(config, environment)
        Validator.new config, environment, &validation
      end

      def config_file_path
        @config_file_path ||= config_file_paths.find { |path| File.exist? path } or
            raise "no config file found, candidates: #{config_file_paths.join ' '}"
      end
    end
  end
end