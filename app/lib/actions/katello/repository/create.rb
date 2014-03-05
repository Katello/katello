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

        middleware.use Actions::Middleware::RemoteAction

        def plan(repository, clone = false)
          repository.disable_auto_reindex!
          repository.save!
          action_subject(repository)
          plan_self

          #check the instance variable, as we do not want to go to pulp
          checksum_type = repository.checksum_type if self.instance_variable_get('@checksum_type')
          if repository.puppet?
            path = File.join(::Katello.config.puppet_repo_root,
                             ::Katello::KTEnvironment.construct_name(repository.environment.organization,
                                                                     repository.environment,
                                                                     repository.content_view),
                             'modules')
          else
            path = repository.relative_path
          end
          sequence do
            plan_action(Katello::Product::ContentCreate, repository) unless clone
            plan_action(Pulp::Repository::Create,
                        content_type: repository.content_type,
                        pulp_id: repository.pulp_id,
                        name: repository.name,
                        feed: repository.feed,
                        ssl_ca_cert: repository.feed_ca,
                        ssl_client_cert: repository.feed_cert,
                        ssl_client_key: repository.feed_key,
                        unprotected: repository.unprotected,
                        checksum_type: checksum_type,
                        path: path,
                        with_importer: true)
            unless clone
              plan_action(Katello::Repository::MetadataGenerate, repository)
              plan_action(ElasticSearch::Reindex, repository)
            end
          end

        end

        def humanized_name
          _("Create")
        end

        def finalize
          repository = ::Katello::Repository.find(input[:repository][:id])
          org = repository.product.organization
          # TODO: should be done in Katello::ContentView::UpdateEnvironment
          org.default_content_view.update_cp_content(org.library)
        end

      end
    end
  end
end
