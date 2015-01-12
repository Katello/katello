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
  class DockerImage < Katello::Model
    include Glue::Pulp::PulpContentUnit

    has_many :docker_tags, :dependent => :destroy, :class_name => "Katello::DockerTag"
    has_many :repository_docker_images, :dependent => :destroy
    has_many :repositories, :through => :repository_docker_images, :inverse_of => :docker_images

    validates :image_id, presence: true, uniqueness: true

    CONTENT_TYPE = "docker"
    scoped_search :on => :image_id, :rename => :name

    def self.repository_association_class
      RepositoryDockerImage
    end

    def update_from_json(json)
      update_attributes(:image_id => json[:image_id],
                        :size => json[:size]
                       )
    end
  end
end
