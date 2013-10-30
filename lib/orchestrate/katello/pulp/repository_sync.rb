#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Orchestrate
  module Katello
    module Pulp

    class PollingServiceImpl < Dynflow::MicroActor

      Task = Algebrick.type do
        fields(action:    Dynflow::Action::Suspended,
               pulp_user: String,
               task_id:   String)
      end

      Tick = Algebrick.type

      def initialize(logger)
        super(logger)
        @tasks    = Set.new
        @progress = Hash.new { |h, k| h[k] = 0 }

        @start_ticker = Queue.new
        @ticker       = Thread.new do
          loop do
            sleep interval
            self << Tick
            @start_ticker.pop
          end
        end
      end

      def wait_for_task(action, pulp_user, task_id)
        # simulate polling for the state of the external task
        self << Task[action,
                     pulp_user,
                     task_id]
      end

      private

      def interval
        0.5
      end

      def on_message(message)
        match(message,
              ~Task >>-> task do
                @tasks << task
              end,
              Tick >>-> do
                poll
              end)
      end

      def tick
        @start_ticker << true
      end

      def as_pulp_user(pulp_user)
        ret = nil
        User.set_pulp_config(pulp_user) do
          ret = yield
        end
        return ret
      end

      def poll
        @tasks.delete_if do |task|
          as_pulp_user(task[:pulp_user]) do
            pulp_task = ::Katello.pulp_server.resources.task.poll(task[:task_id])
            done = !! pulp_task[:finish_time]
            task[:action].update_progress(done, pulp_task)
            done
          end
        end
      ensure
        tick
      end
    end

    PollingService = PollingServiceImpl.new(Logging.logger['glue'])


      class RepositorySync < Dynflow::Action

        include Helpers::RemoteAction

        input_format do
          param :repo_id, Integer
        end

        def run
          sync_options = {}
          sync_options[:max_speed] ||= ::Katello.config.pulp.sync_KBlimit if ::Katello.config.pulp.sync_KBlimit # set bandwidth limit
          sync_options[:num_threads] ||= ::Katello.config.pulp.sync_threads if ::Katello.config.pulp.sync_threads # set threads per sync

          pulp_tasks = pulp.repository.sync(input[:pulp_id], { override_config: sync_options })
          output[:pulp_tasks] = pulp_tasks

          # TODO: would be better polling for the whole task group to make sure we're really finished at the end
          sync_task = pulp_tasks.find do |task|
            task['tags'].include?("pulp:action:sync")
          end
          output[:sync_task] = sync_task
          output[:task_id] = sync_task['task_id']
          suspend
        end


        def setup_suspend(suspended_action)
          PollingService.wait_for_task(suspended_action, input[:remote_user], output[:task_id])
        end

        def update_progress(done, pulp_task)
          output.update sync_task: pulp_task, done: done
        end

        def run_progress
          sync_task = output[:sync_task]
          if sync_task &&
                sync_task[:progress] &&
                sync_task[:progress][:yum_importer] &&
                (content_progress = sync_task[:progress][:yum_importer][:content])
            if content_progress[:size_total].to_i > 0
              left = content_progress[:size_left].to_f / content_progress[:size_total]
              return 1 - left
            else
              return 0.01
            end
          else
            return 0.01
          end
        end

        def run_progress_weight
          10
        end

      end
    end
  end
end
