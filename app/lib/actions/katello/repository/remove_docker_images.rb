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

module Actions
  module Katello
    module Repository
      class RemoveDockerImages < Actions::EntryAction
        def plan(options)
          plan_self(options)
        end

        def run
          repo = ::Katello::Repository.in_default_view.find_by_pulp_id(input['pulp_id'])
          images = repo.docker_images.with_uuid(input['uuids'])
          repo.docker_tags.where(:docker_image_id => images.map(&:id)).destroy_all
          repo.docker_images -= images

          # destroy any orphan docker images
          images.reload.each do |image|
            image.destroy if image.repositories.count < 1
          end
        end
      end
    end
  end
end
