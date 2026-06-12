namespace :katello do
  namespace :upgrades do
    namespace '4.21' do
      # Helper method to bulk-load template invocation input values
      # Only loads list-based template input ('errata'). Search-based templates require Dynflow.
      def self.bulk_load_template_input_values(tasks)
        template_invocation_ids = tasks.map { |t| t.template_invocation&.id }.compact
        input_values_map = {}
        if template_invocation_ids.any?
          ::TemplateInvocationInputValue
            .joins(:template_input)
            .where(template_invocation_id: template_invocation_ids)
            .where("template_inputs.name = ?", 'errata')
            .pluck(:template_invocation_id, :value)
            .each { |ti_id, value| input_values_map[ti_id] = value }
        end
        input_values_map
      end

      # Helper method to bulk-load host_id and errata IDs from Dynflow action scripts
      # Queries dynflow_actions table directly and extracts both host_id and RESOLVED_ERRATA_IDS
      def self.bulk_load_from_dynflow(tasks)
        task_ids = tasks.map(&:id)
        host_id_map = {}
        script_errata_map = {}

        return [host_id_map, script_errata_map] if task_ids.empty?

        db = dynflow_database
        return [host_id_map, script_errata_map] unless db

        query_dynflow_actions(db, task_ids, host_id_map, script_errata_map)
        [host_id_map, script_errata_map]
      end

      def self.dynflow_database
        ForemanTasks.dynflow.world.persistence.adapter.db
      rescue StandardError => e
        Rails.logger.warn("Dynflow not available for bulk extraction: #{e.message}")
        nil
      end

      def self.query_dynflow_actions(db, task_ids, host_id_map, script_errata_map)
        actions = db[:dynflow_actions]
          .join(:dynflow_execution_plans, uuid: :execution_plan_uuid)
          .join(:foreman_tasks_tasks, Sequel.lit('external_id = dynflow_execution_plans.uuid::text'))
          .where(Sequel.lit('dynflow_actions.class = ?', 'Actions::RemoteExecution::ProxyAction'))
          .where(Sequel.lit('foreman_tasks_tasks.id IN ?', task_ids))
          .select(Sequel.lit('foreman_tasks_tasks.id AS task_id, dynflow_actions.input'))

        actions.each do |row|
          process_dynflow_action_row(row, host_id_map, script_errata_map)
        end
      end

      def self.process_dynflow_action_row(row, host_id_map, script_errata_map)
        task_id = row[:task_id]
        return if row[:input].nil?

        require 'msgpack'
        input_hash = MessagePack.unpack(row[:input].to_s)

        extract_host_id(task_id, input_hash, host_id_map)
        extract_errata_from_script(task_id, input_hash, script_errata_map)
      rescue StandardError => e
        Rails.logger.warn("Failed to extract data from task #{task_id}: #{e.message}")
      end

      def self.extract_host_id(task_id, input_hash, host_id_map)
        if input_hash['host'].is_a?(Hash)
          host_id_map[task_id] = input_hash['host']['id']
        elsif input_hash['host_id']
          host_id_map[task_id] = input_hash['host_id']
        end
      end

      def self.extract_errata_from_script(task_id, input_hash, script_errata_map)
        script = input_hash['script']
        return if script.blank?

        found = script.lines.find { |line| line.start_with?('# RESOLVED_ERRATA_IDS=') }
        return unless found

        errata_ids = found.chomp.split('=', 2).last.split(',').map(&:strip).reject(&:blank?)
        script_errata_map[task_id] = errata_ids if errata_ids.any?
      end

      # Helper method to parse comma-separated errata IDs
      def self.parse_comma_separated_errata_ids(value)
        return [] if value.blank?
        value.split(',').map(&:strip).reject(&:blank?)
      end

      # Helper method to bulk record errata applications
      def self.bulk_record_from_tasks(tasks)
        records = []
        current_time = Time.zone.now

        # Bulk-load data from both sources:
        # 1. Search-based: host_id and errata_ids from Dynflow (bulk SQL query on dynflow_actions)
        # 2. List-based: errata_ids from template inputs (bulk SQL query on template_invocation_input_values)
        host_id_map, script_errata_map = bulk_load_from_dynflow(tasks)
        input_values_map = bulk_load_template_input_values(tasks)

        # Build records using pre-loaded maps (no individual Dynflow access)
        tasks.each do |task|
          # Try Dynflow map first (search-based), then template_invocation (list-based)
          host_id = host_id_map[task.id] || task.template_invocation&.host_id
          next unless host_id

          # Try script map first (search-based), then template input map (list-based)
          errata_string_ids = script_errata_map[task.id]
          if errata_string_ids.blank? && task.template_invocation
            value = input_values_map[task.template_invocation.id]
            errata_string_ids = parse_comma_separated_errata_ids(value) if value.present?
          end

          next if errata_string_ids.blank?

          status = Katello::ErrataApplication.determine_status(task, nil)

          records << {
            host_id: host_id,
            errata_ids: errata_string_ids,
            task_id: task.id,
            user_id: task.user_id,
            applied_at: task.ended_at || current_time,
            status: status,
            created_at: current_time,
            updated_at: current_time,
          }
        end

        # Bulk insert, skip duplicates based on unique constraint
        if records.any?
          Katello::ErrataApplication.insert_all(records, unique_by: [:host_id, :task_id])
          records.size
        else
          0
        end
      end

      # Helper method for parallel processing
      def self.process_with_parallelization(task_ids, batch_limit, total)
        return { created: 0, skipped: 0, errors: 0 } if total.zero?

        before_count = Katello::ErrataApplication.count

        all_batches = prepare_batches(batch_limit, total)
        counters = { mutex: Mutex.new, processed: 0, errors: 0 }

        threads = create_worker_threads(task_ids, all_batches, counters)
        threads.each(&:join)

        after_count = Katello::ErrataApplication.count
        actual_created = after_count - before_count
        actual_skipped = total - actual_created - counters[:errors]

        ActiveRecord::Base.clear_active_connections!
        puts "Migration complete: #{actual_created} created, #{actual_skipped} skipped, #{counters[:errors]} errors"
      end

      def self.prepare_batches(batch_limit, total)
        batch_count = (total.to_f / batch_limit).ceil
        Array.new(batch_count) do |index|
          start_idx = index * batch_limit
          end_idx = [start_idx + batch_limit, total].min
          { start_idx: start_idx, end_idx: end_idx, index: index }
        end
      end

      def self.create_worker_threads(task_ids, all_batches, counters)
        thread_count = [4, all_batches.size].min
        batches_per_thread = (all_batches.size.to_f / thread_count).ceil
        threads = []

        thread_count.times do |i|
          thread_batches = all_batches[i * batches_per_thread, batches_per_thread]
          next if thread_batches.blank?

          threads << create_worker_thread(task_ids, thread_batches, all_batches.size, counters)
        end
        threads
      end

      def self.create_worker_thread(task_ids, thread_batches, total_batches, counters)
        Thread.new do
          User.current = User.anonymous_api_admin
          ActiveRecord::Base.connection_pool.with_connection do
            thread_batches.each { |batch_data| process_batch(task_ids, batch_data, total_batches, counters) }
          end
        end
      end

      def self.process_batch(task_ids, batch_data, total_batches, counters)
        index = batch_data[:index]
        batch_ids = task_ids[batch_data[:start_idx]...batch_data[:end_idx]]
        batch = ForemanTasks::Task.where(id: batch_ids).includes(:template_invocation).to_a

        count = bulk_record_from_tasks(batch)
        update_counters(counters, count, 0, index, total_batches)
      rescue => e
        handle_batch_error(counters, batch.size, index, e)
      end

      def self.update_counters(counters, processed, errors, index, total_batches)
        counters[:mutex].synchronize do
          counters[:processed] += processed
          counters[:errors] += errors
          puts "  Completed batch #{index + 1} of #{total_batches} (processed: #{processed})"
        end
      end

      def self.handle_batch_error(counters, batch_size, index, error)
        counters[:mutex].synchronize do
          counters[:errors] += batch_size
          puts "ERROR: Failed to process batch #{index + 1}: #{error.message}"
          Rails.logger.error("Failed to process batch #{index + 1}: #{error.message}")
          Rails.logger.error(error.backtrace.join("\n"))
        end
      end

      desc "Populate errata application records from historical RunHostJob tasks"
      task :populate_errata_applications => ['environment', 'dynflow:client'] do
        User.current = User.anonymous_api_admin

        batch_size = 5000

        # Load task IDs upfront to avoid repeated expensive .distinct queries
        puts "Loading task IDs..."
        task_ids = ForemanTasks::Task
          .joins(template_invocation: { template: :remote_execution_features })
          .where(label: 'Actions::RemoteExecution::RunHostJob')
          .where('remote_execution_features.label': ['katello_errata_install', 'katello_errata_install_by_search'])
          .where.not(started_at: nil)
          .distinct
          .pluck(:id)

        total = task_ids.size
        puts "Found #{total} errata install tasks to process"
        puts "Using parallel processing (#{[4, (total.to_f / batch_size).ceil].min} threads)"

        process_with_parallelization(task_ids, batch_size, total)

        # Force clean exit
        exit 0
      end
    end
  end
end
