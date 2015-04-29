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
      class Create < Actions::EntryAction
        # rubocop:disable MethodLength
        def plan(repository, clone = false, plan_create = false)
          repository.disable_auto_reindex!
          repository.save!
          action_subject(repository)

          org = repository.organization
          path = repository.relative_path unless repository.puppet?

          create_action = plan_create ? Actions::Pulp::Repository::CreateInPlan : Actions::Pulp::Repository::Create
          sequence do
            create_action = plan_action(create_action,
                                        content_type: repository.content_type,
                                        pulp_id: repository.pulp_id,
                                        name: repository.name,
                                        docker_upstream_name: repository.docker_upstream_name,
                                        feed: repository.url,
                                        ssl_ca_cert: repository.feed_ca,
                                        ssl_client_cert: repository.feed_cert,
                                        ssl_client_key: repository.feed_key,
                                        unprotected: repository.unprotected,
                                        checksum_type: repository.checksum_type,
                                        path: path,
                                        with_importer: true)

            return if create_action.error

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            unless clone
              if repository.product.redhat?
                plan_action(ContentView::UpdateEnvironment, org.default_content_view,
                            org.library, repository.content_id)
              else
                content_create = plan_action(Katello::Product::ContentCreate, repository)
                plan_action(ContentView::UpdateEnvironment, org.default_content_view,
                            org.library, content_create.input[:content_id])
              end
            end

            concurrence do
              plan_action(::Actions::Pulp::Repos::Update, repository.product) if repository.product.sync_plan
              plan_self(:repository_id => repository.id) unless repository.puppet?
              plan_action(ElasticSearch::Reindex, repository)
            end
          end
        end

        def run
          ::User.current = ::User.anonymous_api_admin
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
        ensure
          ::User.current = nil
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
