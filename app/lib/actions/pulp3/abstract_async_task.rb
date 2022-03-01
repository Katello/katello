module Actions
  module Pulp3
    class AbstractAsyncTask < Pulp3::Abstract
      include Actions::Base::Polling
      include ::Dynflow::Action::Cancellable

      def run(event = nil)
        # do nothing when the action is being skipped
        unless event == Dynflow::Action::Skip
          super
        end
      end

      def humanized_state
        case state
        when :running
          if self.combined_tasks.empty?
            _("initiating Pulp task")
          else
            _("checking Pulp task status")
          end
        when :suspended
          if combined_tasks.any?(&:started?)
            _("waiting for Pulp to finish the task")
          else
            _("waiting for Pulp to start the task")
          end
        else
          super
        end
      end

      def done?
        combined_tasks&.all? { |task| task.done? }
      end

      def external_task
        #this must return nil until external_task= is called
        combined_tasks
      end

      def combined_tasks
        return nil if pulp_tasks.nil? || task_groups.nil?
        pulp_tasks + task_groups
      end

      def pulp_tasks
        return nil if output[:pulp_tasks].nil?
        output[:pulp_tasks] = new_or_existing_objects(::Katello::Pulp3::Task, output[:pulp_tasks])
      end

      def task_groups
        return nil if output[:task_groups].nil?
        output[:task_groups] = new_or_existing_objects(::Katello::Pulp3::TaskGroup, output[:task_groups])
      end

      def new_or_existing_objects(object_class, objects)
        objects.map do |object|
          if object.is_a?(object_class)
            object
          else
            object_class.new(smart_proxy, object)
          end
        end
      end

      def cancel!
        cancel
        poll_external_task
        # We suspend the action and the polling will take care of finding
        # out if the cancelling was successful
        suspend unless done?
      end

      def cancel
        pulp_tasks.each { |task| task.cancel }
        task_groups.each { |task_group| task_group.cancel }
      end

      def rescue_external_task(error)
        if error.is_a?(::Katello::Errors::Pulp3Error)
          fail error
        else
          super
        end
      end

      private

      def transform_task_response(response)
        response = [] if response.nil?
        response = [response] unless response.is_a?(Array)
        response = response.map do |task|
          task.as_json
        end
        response
      end

      def missing_resources_message(error)
        migration_task = pulp_tasks.any? { |task| task[:name] == 'pulp_2to3_migration.app.tasks.migrate.migrate_from_pulp2' }
        if migration_task && error&.starts_with?("Validation failed: resources missing")
          "Missing repositories found, please run 'COMMIT=true foreman-rake katello:correct_repositories'.  Original error: #{error}"
        else
          error
        end
      end

      def check_for_errors
        combined_tasks.each do |task|
          if (message = missing_resources_message(task.error))
            fail ::Katello::Errors::Pulp3Error, message
          end
        end
      end

      def external_task=(external_task_data)
        #currently we assume everything coming from invoke_external_task_methods are tasks
        tasks = transform_task_response(external_task_data)
        output[:pulp_tasks] = new_or_existing_objects(::Katello::Pulp3::Task, tasks)

        add_task_groups
        check_for_errors
      end

      def add_task_groups
        output[:task_groups] ||= []
        pulp_tasks.each do |task|
          if task.task_group_href && !tracking_task_group?(task.task_group_href)
            output[:task_groups] << ::Katello::Pulp3::TaskGroup.new_from_href(smart_proxy, task.task_group_href)
          end
        end
      end

      def tracking_task_group?(href)
        task_groups&.any? { |group| group.href == href }
      end

      def poll_external_task
        pulp_tasks.each(&:poll)
        output[:task_groups] = task_groups.each(&:poll) if task_groups
        add_task_groups
        check_for_errors
        pulp_tasks
      end
    end
  end
end
