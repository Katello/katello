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
                  consumer_cert_rpm))

        booleans? :use_cp, :use_pulp, :use_elasticsearch
      end,

      :config_post_process => lambda do |config, _environment|
        config[:use_cp] = true if config[:use_cp].nil?
        config[:use_pulp] = true if config[:use_pulp].nil?
        config[:use_elasticsearch] = true if config[:use_elasticsearch].nil?
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
