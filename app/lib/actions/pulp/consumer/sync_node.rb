module Actions
  module Pulp
    module Consumer
      class SyncNode < AbstractSyncNodeTask
        input_format do
          param :consumer_uuid, String
          param :repo_ids, Array
          param :skip_content
        end

        def invoke_external_task
          if input[:repo_ids]
            pulp_extensions.consumer.update_content(input[:consumer_uuid],
                                                    'repository',
                                                    input[:repo_ids],
                                                    options)
          else
            pulp_extensions.consumer.update_content(input[:consumer_uuid], 'node',  nil, options)
          end
        end

        def options
          ret = {}
          # skip_content_update means we want just to make sure only binded repositories are
          # on the node, but no content is being transferred: this way, we can
          # propagate repository deletion to the attached capsules without full sync
          ret[:skip_content_update] = true if input[:skip_content]
          ret
        end

        def rescue_strategy_for_self
          # There are various reasons the syncing fails, not all of them are
          # fatal: when fail on syncing, we continue with the task ending up
          # in the warning state, but not locking further syncs
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
