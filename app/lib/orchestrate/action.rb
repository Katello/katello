module Orchestrate
  class Action < Dynflow::Action

    # This method says what data form input gets into the task details in Rest API
    # By default, it sends the whole input there.
    def task_input
      self.input
    end

    # This method says what data form output gets into the task details in Rest API
    # It should aggregate the important data that are worth to propagate to Rest API,
    # perhaps also aggraget data from subactions if needed (using +all_actions+) method
    # of Dynflow::Action::Presenter
    def task_output
      self.output
    end

    # This method should return humanized description of the action, e.g. "Install Package"
    def humanized_name
      action_class.name[/\w+$/].gsub(/([a-z])([A-Z])/) { "#{$1} #{$2}" }
    end

    # This method should return String of Array<String> describing input for the task
    def humanized_input
      task_input.pretty_inspect
    end

    # This method should return String describing output for the task.
    # It should aggregate the data from subactions as well and it's used for humanized
    # description of restuls of the action
    def humanized_output
      task_output.pretty_inspect
    end

  end
end
