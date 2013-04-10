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

module Resources

  # Resources::Foreman defines constants holding configured instances of ForemanApi::Resources::* classes.
  module Foreman

    def self.options
      @options ||= begin
        config = Katello.config.foreman
        { :base_url           => config.url,
          :enable_validations => false,
          :oauth              => { :consumer_key    => config.oauth_key,
                                   :consumer_secret => config.oauth_secret },
          :logger             => Logging.logger['foreman_rest'] }
      end
    end

    def self.timeout_options
      { :open_timeout => Katello.config.rest_client_timeout,
        :timeout      => Katello.config.rest_client_timeout }
    end

    Architecture    = ForemanApi::Resources::Architecture.new options, timeout_options
    Bookmark        = ForemanApi::Resources::Bookmark.new options, timeout_options
    Home            = ForemanApi::Resources::Home.new options, timeout_options
    OperatingSystem = ForemanApi::Resources::OperatingSystem.new options, timeout_options
    User            = ForemanApi::Resources::User.new options, timeout_options
    Domain          = ForemanApi::Resources::Domain.new options, timeout_options
    SmartProxy      = ForemanApi::Resources::SmartProxy.new options, timeout_options
    Subnet          = ForemanApi::Resources::Subnet.new options, timeout_options
    ConfigTemplate  = ForemanApi::Resources::ConfigTemplate.new options, timeout_options
    ComputeResource = ForemanApi::Resources::ComputeResource.new options, timeout_options
    HardwareModel   = ForemanApi::Resources::Model.new options, timeout_options

  end
end
