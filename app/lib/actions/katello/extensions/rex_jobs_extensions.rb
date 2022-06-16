module Actions
  module Katello
    module Extensions
      module RexJobsExtensions
        def cleanup_rules
          ::ForemanTasks::ActionRule.new(self, '90d', 'remote_execution_feature.label = katello_errata_install')
        end
      end
    end
  end
end
