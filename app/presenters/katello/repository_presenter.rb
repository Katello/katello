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
  class RepositoryPresenter
    attr_accessor :repository

    def initialize(repository)
      @repository = repository
    end

    def content_view_environments
      unarchived = @repository.clones.select { |clone| clone.environment && clone.content_view_version }

      unarchived.collect do |repository|
        if repository.environment && repository.content_view_version
          {
            :content_view_version => {
              :id => repository.content_view_version.id,
              :name => repository.content_view_version.name
            },
            :environment => {
              :id => repository.environment.id,
              :name => repository.environment.name
            }
          }
        end
      end
    end
  end
end
