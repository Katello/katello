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
    module DockerImageExtensions
      extend ActiveSupport::Concern

      included do
        CONTENT_TYPE = "docker"

        has_many :repositories, :through => :repository_docker_images, :class_name => "Katello::Repository"
        has_many :repository_docker_images, :class_name => "Katello::RepositoryDockerImage", :dependent => :destroy, :inverse_of => :docker_image

        scoped_search :on => :image_id, :rename => :name
      end

      module ClassMethods
        def repository_association_class
          RepositoryDockerImage
        end

        def with_uuid(uuids)
          where(:katello_uuid => uuids)
        end
      end

      def update_from_json(json)
        update_attributes(:image_id => json[:image_id],
                          :size => json[:size]
                         )
      end

      def uuid=(uuid)
        self.katello_uuid = uuid
      end

      def uuid
        katello_uuid
      end
    end
  end
end
