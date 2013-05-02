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

module Glue
  singleton_class.send :attr_writer, :logger
  def self.logger
    @logger ||= Logging.logger['glue']
  end

  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      attr_reader :old

      before_validation :setup_clone

      around_save :on_save
      around_destroy :on_destroy
    end
  end

  module InstanceMethods

    def on_save
      Glue.logger.debug "Processing on save pre-queue: #{pre_queue.to_log}" if pre_queue.count > 0
      process pre_queue
      yield if block_given?
      Glue.logger.debug "Processing on save post-queue: #{post_queue.to_log}" if post_queue.count > 0
      process post_queue
      @orchestration_for = nil
    end

    def on_destroy
      return false unless errors.empty?

      Glue.logger.debug "Processing on destroy pre-queue: #{pre_queue.to_log}" if pre_queue.count > 0
      process(pre_queue)
      yield if block_given?
      Glue.logger.debug "Processing on destroy post-queue: #{post_queue.to_log}" if post_queue.count > 0
      process post_queue
      @orchestration_for = nil
    end

    # type of operation for this orchestration, ie: crud, product promotion
    def orchestration_for
      @orchestration_for ||= new_record? ? :create : :update
    end

    def orchestration_for=(val)
      @orchestration_for = val.to_sym
    end

    def rollback
      Glue.logger.warning "Rollback initiated"
      Glue.logger.warning "Before rollback pre-queue: #{pre_queue.to_log}"
      Glue.logger.warning "Before rollback post-queue: #{post_queue.to_log}"
      raise ActiveRecord::Rollback
    end

    def pre_queue
      @pre_queue ||= Glue::Queue.new
    end

    def post_queue
      @post_queue ||= Glue::Queue.new(pre_queue)
    end

    public
    # we override this method in order to include checking the
    # after validation callbacks status, as rails by default does
    # not care about their return status.
    def valid?(context = nil)
      super
      errors.empty?
    end

    # we override the destroy method, in order to ensure our queue exists before other callbacks
    # and to process the queue only if we found no errors
    def destroy
      @orchestration_for ||= :destroy
      pre_queue
      post_queue
      super
    end

    def proxy_error e
      (e.respond_to?(:response) and !e.response.nil?) ? e.response : e
    end

    protected
    # Handles the actual queue
    # takes care for running the tasks in order
    # if any of them fail, it rollbacks all completed tasks
    # in order not to keep any left overs in our proxies.
    def process q
      # queue is empty - nothing to do.
      return if q.empty?

      # process all pending tasks
      q_total = q.pending.count
      q_active = 1
      q.pending.each do |task|
        # if we have failures, we don't want to process any more tasks
        next unless q.failed.empty?

        # send into orchestration log
        obj, met, *args = task.action
        args_str = args.collect { |x| x.inspect }.join(",")[0, 20]
        obj_id = ''
        obj_id = "find(#{obj.id})." if obj.respond_to?(:id) && obj.id
        Glue.logger.info "Task #{task.name} (#{q_active}/#{q_total}) > #{obj.class.name}.#{obj_id}#{met}(#{args_str})"

        # execute the task
        task.status = "running"
        task.status = execute({:action => task.action}) ? "completed" : "failed"
        q_active += 1
      end

      # if we have no failures - we are done
      return true if (errors.empty? && q.failed.empty?)
      raise Errors::OrchestrationException.new("Errors occurred during orchestration #{errors.inspect}\n Queue Failed - #{q.failed.inspect}" )
    rescue => e
      logger.error "Rolling back due to a problem: #{q.failed}\n#{e.inspect} \n#{e.backtrace.join('\n')}"
      # handle errors
      # we try to undo all completed operations and trigger a DB rollback
      (q.completed + q.running).sort.reverse_each do |task|
        begin
          task.status = "rollbacked"
          execute({:action => task.action, :action_rollback => task.action_rollback, :rollback => true})
        rescue => rollback_exception
          # if the operation failed, we can just report upon it
          logger.error "Failed to perform rollback on #{task.name} - #{rollback_exception.inspect}\n  #{rollback_exception.backtrace.join('\n')}"
          errors.add :base, "Failed to perform rollback on #{task.name} - #{rollback_exception}"
        end
      end

      raise e
    end

    def execute opts = {}
      obj, met, *args = opts[:action]
      rollback = opts[:rollback] || false

      # at the moment, the rollback method invoked will be based upon:
      #   1. the :action_rollback specified when the action was queued --or--
      #   2. by replacing set with del in the method name
      if rollback
        if !opts[:action_rollback].nil?
          # user specified a rollback method when queuing the action
          obj, met, *args = opts[:action_rollback]
        else
          met = met.to_s
          case met
          when /set/
            met.gsub!("set","del")
          when /del/
            met.gsub!("del","set")
          else
            raise "Dont know how to rollback #{met}"
          end
          met = met.to_sym
        end
      end
      if obj.respond_to?(met)
        return args.empty? ? obj.send(met) : obj.send(met, *args)
      else
        raise Errors::OrchestrationException.new("invalid method #{met}")
      end
    end

    def setup_clone
      return if new_record?
      @old = self.dup
      for key in (changed_attributes.keys - ["updated_at"])
        @old.send "#{key}=", changed_attributes[key]
      end
    end

  end
end
