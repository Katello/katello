module Actions
  module Pulp
    module RepositoryGroup
      class Export < Pulp::AbstractAsyncTask
        include Helpers::Presenter

        input_format do
          param :id
          param :export_to_iso
          param :export_directory # NB: this param is only used when not exporting to ISO
          param :start_date
          param :iso_size
        end

        def invoke_external_task
          override_config = {}

          if input[:start_date]
            override_config[:start_date] = input[:start_date]
          end

          if input[:iso_size]
            override_config[:iso_size] = input[:iso_size]
          end

          unless input[:export_to_iso]
            override_config[:export_dir] = input[:export_directory]
          end

          optional = {:override_config => override_config}

          pulp_resources.
            repository_group.publish(input[:id], distributor_id(input[:id]), optional)
        end

        private

        def distributor_id(pulp_id)
          distributor = repo_group_distributors(pulp_id).find do |dist|
            dist["distributor_type_id"] == 'group_export_distributor'
          end
          distributor['id']
        end

        def repo_group_distributors(pulp_id)
          pulp_resources.repository_group.retrieve_distributors(pulp_id)
        end
      end
    end
  end
end
