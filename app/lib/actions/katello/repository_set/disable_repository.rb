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
    module RepositorySet
      class DisableRepository < Actions::EntryAction
        def humanized_name
          _("Disable")
        end

        def plan(product, content, options)
          if repository = repository_mapper(product,
                                            content,
                                            options,
                                            options[:registry_name]).find_repository
            action_subject(repository)
            plan_action(ElasticSearch::Reindex, repository.product)
            plan_action(Repository::Destroy, repository)
          else
            fail ::Katello::Errors::NotFound, _('Repository not found')
          end
        end

        private

        def repository_mapper(product, content, substitutions, registry_name)
          if content.type == ::Katello::Repository::CANDLEPIN_DOCKER_TYPE
            ::Katello::Candlepin::Content::DockerRepositoryMapper.new(product,
                                                                content,
                                                                registry_name)

          else
            ::Katello::Candlepin::Content::RepositoryMapper.new(product,
                                                                content,
                                                                substitutions)
          end
        end
      end
    end
  end
end
