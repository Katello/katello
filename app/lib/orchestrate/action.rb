module Orchestrate
  class Action < Dynflow::Action

    # This method says what data form input gets into the task details in Rest API
    # By default, it sends the whole input there.
    def task_input
      self.input
    end

    # This method says what data form output gets into the task details in Rest API
    # By default, it sends the whole input there.
    def task_output
      self.output
    end

  end
end
