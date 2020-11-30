module Actions
  module Pulp3
    module Repository
      class UploadTag < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy, args)
          plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :args => args)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find(input[:repository_id])
          tag_name = input[:args].dig(:unit_key, :name)
          manifest_digest = input[:args].dig(:unit_key, :digest)
          output[:pulp_tasks] = [repo.backend_service(smart_proxy).tag_manifest(tag_name, manifest_digest)]
        end
      end
    end
  end
end
