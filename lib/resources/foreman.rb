#
# Copyright 2011 Red Hat, Inc.
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
                                   :consumer_secret => config.oauth_secret } }
      end
    end

    Architecture    = ForemanApi::Resources::Architecture.new options
    Bookmark        = ForemanApi::Resources::Bookmark.new options
    Home            = ForemanApi::Resources::Home.new options
    OperatingSystem = ForemanApi::Resources::OperatingSystem.new options
    User            = ForemanApi::Resources::User.new options
    Domain          = ForemanApi::Resources::Domain.new options
    SmartProxy      = ForemanApi::Resources::SmartProxy.new options
    Subnet          = ForemanApi::Resources::Subnet.new options
    ConfigTemplate  = ForemanApi::Resources::ConfigTemplate.new options
    ComputeResource = ForemanApi::Resources::ComputeResource.new options

  end
end
