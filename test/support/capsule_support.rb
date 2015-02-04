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

module Support
  module CapsuleSupport
    def pulp_feature
      @pulp_feature ||= Feature.create(name: SmartProxy::PULP_NODE_FEATURE)
    end

    def proxy_with_pulp
      @proxy_with_pulp ||= smart_proxies(:four).tap do |proxy|
        unless proxy.features.include?(pulp_feature)
          proxy.features << pulp_feature
        end
      end
    end

    def capsule_content
      @capsule_content ||= Katello::CapsuleContent.new(proxy_with_pulp)
    end
  end
end
