module Actions
  module Pulp
    module ExpectOneTask
      def external_task=(external_task_data)
        external_task_data = [external_task_data] unless external_task_data.is_a?(Array)
        fail "Not expecting more than one task" if external_task_data.length  > 1
        super(external_task_data)
      end
    end
  end
end
