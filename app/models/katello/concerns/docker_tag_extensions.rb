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
    module DockerTagExtensions
      extend ActiveSupport::Concern

      included do
        belongs_to :repository, :inverse_of => :docker_tags, :foreign_key => :katello_repository_id,
          :class_name => "Katello::Repository"

        scoped_search :on => [:id, :tag]
      end

      # docker tag only has one repo
      def repositories
        [repository]
      end

      module ClassMethods
        def in_repositories(repos)
          where(:katello_repository_id => repos)
        end

        # docker tag doesn't have a uuid in pulp
        def with_uuid(uuid)
          where(:id => uuid)
        end
      end
    end
  end
end
