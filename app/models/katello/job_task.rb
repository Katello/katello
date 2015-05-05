module Katello
  class JobTask < Katello::Model
    self.include_root_in_json = false

    belongs_to :job, :inverse_of => :job_tasks
    belongs_to :task_status, :inverse_of => :job_task

    validates_lengths_from_database
  end
end
