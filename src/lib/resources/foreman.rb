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
  module Foreman
    config  = AppConfig.foreman
    options = { :base_url => config.url,
                :oauth    => { :consumer_key    => config.oauth_key,
                               :consumer_secret => config.oauth_secret } }

    Architecture    = ForemanApi::Resources::Architecture.new options
    Bookmark        = ForemanApi::Resources::Bookmark.new options
    Home            = ForemanApi::Resources::Home.new options
    OperatingSystem = ForemanApi::Resources::OperatingSystem.new options
    User            = ForemanApi::Resources::User.new options
    Domain          = ForemanApi::Resources::Domain.new options
    ConfigTemplate  = ForemanApi::Resources::ConfigTemplate.new options

  end
end
