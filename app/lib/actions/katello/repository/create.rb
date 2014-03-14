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
        def plan(repository, clone = false)
          repository.disable_auto_reindex!
          repository.save!
          action_subject(repository)
          plan_self

          org = repository.organization
          path = repository.relative_path if repository.puppet?

          sequence do
            plan_action(Actions::Pulp::Repository::Create,
                        content_type: repository.content_type,
                        pulp_id: repository.pulp_id,
                        name: repository.name,
                        feed: repository.feed,
                        ssl_ca_cert: repository.feed_ca,
                        ssl_client_cert: repository.feed_cert,
                        ssl_client_key: repository.feed_key,
                        unprotected: repository.unprotected,
                        checksum_type: repository.checksum_type,
                        path: path,
                        with_importer: true)

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            unless clone
              unless repository.product.redhat?
                content_create = plan_action(Katello::Product::ContentCreate, repository)
                plan_action(ContentView::UpdateEnvironment, org.default_content_view, org.library, content_create.input[:content_id])
              end
              plan_action(Katello::Repository::MetadataGenerate, repository) unless repository.puppet?
              plan_action(ElasticSearch::Reindex, repository)
            end
          end
        end

        def humanized_name
          _("Create")
        end

      end
    end
  end
end
