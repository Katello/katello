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

module Katello
  class Foreman
    def self.update_foreman_content(org, env, content_view)
      # Update the 'content' in foreman.  These actions need to be taken
      # during workflows involving tasks such as content view publishing,
      # refreshing and promotion.

      # The content in foreman that needs to be created/updated includes:
      # 1. install media
      # 2. environment
      # 3. puppet classes

      content_view.repos(env).each{ |repo| Medium.update_media(repo) }

      foreman_environment = Environment.find_or_create_by_katello_id(org, env, content_view)

      if (foreman_smart_proxy = SmartProxy.find_by_name(Katello.config.host))
        PuppetClassImporter.new(:url => foreman_smart_proxy.url).update_environment(foreman_environment)
      end
    end
  end
end
