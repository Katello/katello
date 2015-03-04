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
    def self.create_puppet_environment(org, env, content_view)
      unless content_view.default?
        Environment.find_or_create_by_katello_id(org, env, content_view)
      end
    end

    def self.update_puppet_environment(content_view, environment)
      unless content_view.default?
        content_view_puppet_env = content_view.version(environment).puppet_env(environment)
        foreman_environment = content_view_puppet_env.puppet_environment

        # Associate the puppet environment with the locations that are currently
        # associated with the capsules that have the target lifecycle environment.
        capsule_contents = Katello::CapsuleContent.with_environment(environment, true)
        unless capsule_contents.blank?
          locations = capsule_contents.map(&:capsule).map(&:locations).compact.flatten.uniq
          foreman_environment.locations = locations
          foreman_environment.save!
        end

        if (foreman_smart_proxy = SmartProxy.default_capsule)
          PuppetClassImporter.new(:url => foreman_smart_proxy.url, :env => foreman_environment.name).update_environment
        end
      end
    end
  end
end
