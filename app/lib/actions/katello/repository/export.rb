module Actions
  module Katello
    module Repository
      class Export < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser

        input_format do
          param :id, Integer
          param :export_result, Hash
        end

        # @param repo
        # @param since date for computing incremental exports
        # @param export_suffix suffix to use on export dir
        def plan(repo, since = nil, export_suffix = 'repo_export')
          pulp_override_config = {'export_dir' => File.join(Setting['pulp_export_destination'],
                                                            export_suffix)}
          pulp_override_config[:start_date] = since.iso8601 if since

          plan_action(Pulp::Repository::DistributorPublish,
                      pulp_id: repo.pulp_id,
                      distributor_type_id: Runcible::Models::ExportDistributor.type_id,
                      override_config: pulp_override_config)
        end

        def run
          output[:export_result] = input[:export_result]
        end

        def humanized_name
          _("Export")
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
