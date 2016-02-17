module Actions
  module Pulp
    module RepositoryGroup
      class Create < Pulp::Abstract
        include Helpers::Presenter

        input_format do
          param :id
          param :pulp_ids
        end

        def run
          pulp_resources.
            repository_group.create(input[:id],
                                    :id => input[:id],
                                    :repo_ids => input[:pulp_ids],
                                    :display_name => "temporary group for export",
                                    :distributors => [group_export_distributor])
        rescue RestClient::Conflict
          # if we get a 409 back, a previous run likely died mid-task but it
          # won't hurt this run.
          Rails.logger.info(_("Group %{id} already created.") % {:id => input[:id]})
        end

        def group_export_distributor
          Runcible::Models::GroupExportDistributor.new(false, false)
        end
      end
    end
  end
end
