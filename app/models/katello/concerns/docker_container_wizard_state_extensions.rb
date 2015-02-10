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
  module Concerns
    module DockerContainerWizardStateExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :container_attributes, :katello
      end

      def container_attributes_with_katello
        container_attributes_without_katello.merge(:capsule_id => self.image.capsule_id)
      end
    end
  end
end
