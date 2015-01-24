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
        keys?(*%w(candlepin notification
                  use_cp simple_search_tokens
                  use_pulp cdn_proxy
                  redhat_repository_url
                  elastic_url rest_client_timeout elastic_index
                  pulp
                  logging
                  consumer_cert_rpm))

        validate :logging do
          keys?(*%w(console_inline colorize log_trace loggers))

          validate :loggers do
            keys? 'root'
            validate :root do
              keys? 'level'
              if config[:type] == 'file'
                keys?(*%w(age keep pattern filename))
                keys? 'path' unless early?
              end
            end
          end
        end

        booleans? :use_cp, :use_pulp, :use_elasticsearch
      end,

      :config_post_process      => lambda do |config, environment|
        config[:use_cp] = true if config[:use_cp].nil?
        config[:use_pulp] = true if config[:use_pulp].nil?
        config[:use_elasticsearch] = true if config[:use_elasticsearch].nil?

        root = config.logging.loggers.root
        root[:path] = "#{Rails.root}/log" unless root.key?(:path) if environment
        root[:type] ||= 'file'
      end)
  end

  class << self
    delegate :config, :to => :configuration_loader
    delegate :early_config, :to => :configuration_loader
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

  def self.rpm_package_name(_config)
    package = 'katello'
    rpm = `rpm -q #{package} --queryformat '%{VERSION}-%{RELEASE}' 2>&1`
    $?.exitstatus.zero? ? rpm : N_("Unknown") # rubocop:disable SpecialGlobalVars
  end
end
