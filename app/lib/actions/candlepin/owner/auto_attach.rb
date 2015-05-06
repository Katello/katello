module Actions
  module Candlepin
    module Owner
      class AutoAttach < Candlepin::AbstractAsyncTask
        input_format do
          param :label
        end

        def invoke_external_task
          ::Katello::Resources::Candlepin::Owner.auto_attach(input[:label])
        end
      end
    end
  end
end
