module Katello
  class ContentViewTaskGroup < ::ForemanTasks::TaskGroup
    has_one :content_view, :foreign_key => :task_group_id, :dependent => :nullify, :inverse_of => :task_group, :class_name => "Katello::ContentView"

    def resource_name
      N_('Content View')
    end
  end
end
