#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

path = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH << path unless $LOAD_PATH.include? path

require 'katello/configuration'
require 'katello/app_config'
require 'util/password'

module Katello

  # TODO: clean up this method
  # rubocop:disable MethodLength, BlockAlignment, HashMethods
  # @return [Configuration::Loader] configured for Katello
  def self.configuration_loader
    root = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

    @configuration_loader ||= Configuration::Loader.new(
      :config_file_paths        => %W(#{root}/config/katello.yml
                                      #{Rails.root}/config/settings.plugins.d/katello.yaml
                                      /etc/katello/katello.yml),
      :default_config_file_path => "#{root}/config/katello_defaults.yml",

      :validation               => lambda do |*_|
        has_keys(*%w(app_name candlepin notification available_locales
                     use_cp simple_search_tokens database headpin? host
                     cloud_forms use_pulp cdn_proxy use_ssl warden katello? url_prefix foreman
                     search use_foreman password_reset_expiration redhat_repository_url port
                     elastic_url rest_client_timeout elastic_index
                     katello_version pulp email_reply_address
                     embed_yard_documentation logging system_lang profiling
                     exception_paranoia hide_exceptions consumer_cert_rpm))

        has_values :app_mode, %w(katello headpin)
        has_values :url_prefix, %w(/headpin /sam /katello)
        is_not_empty :system_lang
        is_type :profiling, Array, nil

        validate :logging do
          has_keys(*%w(console_inline colorize log_trace loggers))

          validate :loggers do
            has_keys 'root'
            validate :root do
              has_keys 'level'
              if config[:type] == 'file'
                has_keys(*%w(age keep pattern filename))
                has_keys 'path' unless early?
              end
            end
          end
        end

        unless config.katello?
          is_not_empty :thumbslug_url
        end

        are_booleans :use_cp, :use_foreman, :use_pulp, :use_elasticsearch, :use_ssl,
                     :exception_paranoia, :hide_exceptions

      end,

      :config_post_process      => lambda do |config, environment|
        config[:katello?] = lambda { config.app_mode == 'katello' }
        config[:headpin?] = lambda { config.app_mode == 'headpin' }
        config[:app_name] ||= config.katello? ? 'Katello' : 'Headpin'

        config[:use_cp] = true if config[:use_cp].nil?
        config[:use_pulp] = config.katello? if config[:use_pulp].nil?
        config[:use_foreman] = false if config[:use_foreman].nil?
        config[:use_elasticsearch] = true if config[:use_elasticsearch].nil?

        config[:email_reply_address] = if config[:email_reply_address]
                                         config[:email_reply_address]
                                       else
                                         "no-reply@" + config[:host]
                                       end

        root = config.logging.loggers.root
        root[:path] = "#{Rails.root}/log" unless root.key?(:path) if environment
        root[:type] ||= 'file'

        config[:katello_version] ||= if git_checkout?
                                       git_commit_hash
                                     elsif can_do_shell_command?(:rpm)
                                       rpm_package_name(config)
                                     else
                                       N_("Unknown")
                                     end
      end,

      :load_yml_post_process    => lambda do |config|
        config.each do |env_name, env_config|
          if env_config && env_config.present?(:database)
            database_config = env_config.database
            database_config[:password] = Password.decrypt database_config.password if database_config.present?(:password)
          end
        end
      end)
  end

  # @see Katello::Configuration::Loader#config
  def self.config
    configuration_loader.config
  end

  # @see Katello::Configuration::Loader#early_config
  def self.early_config
    configuration_loader.early_config
  end

  # @return [Hash{String => Hash}] database configurations
  def self.database_configs
    @database_configs ||= begin
                            %w(production development test build).inject({}) do |hash, environment|
                              config_data = configuration_loader.config_data
                              common      = config_data.common.database.to_hash
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

  def self.can_do_shell_command?(cmd)
    system("which #{cmd.to_s} >/dev/null 2>&1")
  end

  def self.git_checkout?
    can_do_shell_command?(:git) && system("cd #{File.dirname(__FILE__)} && git rev-parse --git-dir >/dev/null 2>&1")
  end

  def self.git_commit_hash
    hash = `cd #{File.dirname(__FILE__)} && git rev-parse HEAD 2>/dev/null`.chop
    $?.exitstatus.zero? ? "git: #{hash}" : N_("Unknown") # rubocop:disable SpecialGlobalVars
  end

  def self.rpm_package_name(config)
    package = config.katello? ? 'katello' : 'katello-headpin'
    rpm = `rpm -q #{package} --queryformat '%{VERSION}-%{RELEASE}' 2>&1`
    $?.exitstatus.zero? ? rpm : N_("Unknown") # rubocop:disable SpecialGlobalVars
  end
end
