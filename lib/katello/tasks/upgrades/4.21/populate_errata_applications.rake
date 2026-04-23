namespace :katello do
  namespace :upgrades do
    namespace '4.21' do
      desc "Populate errata application records from historical RunHostJob tasks"
      task :populate_errata_applications => ['environment'] do
        User.current = User.anonymous_api_admin

        batch_size = 1000
        created_count = 0
        skipped_count = 0
        error_count = 0

        tasks = ForemanTasks::Task
          .joins(template_invocation: { template: :remote_execution_features })
          .where(label: 'Actions::RemoteExecution::RunHostJob')
          .where('remote_execution_features.label': ['katello_errata_install', 'katello_errata_install_by_search'])
          .where.not(started_at: nil)
          .distinct

        total = tasks.count
        puts "Found #{total} errata install tasks to process"

        tasks.find_in_batches(batch_size: batch_size).with_index do |batch, index|
          puts "Processing batch #{index + 1} of #{(total.to_f / batch_size).ceil}"

          batch.each do |task|
            begin
              result = Katello::ErrataApplication.record_from_task(task, nil)
              created_count += 1 if result.any?
              skipped_count += 1 if result.empty?
            rescue => e
              error_count += 1
              Rails.logger.warn("Failed to populate errata application for task #{task.id}: #{e.message}")
            end
          end
        end

        puts "Migration complete: #{created_count} created, #{skipped_count} skipped, #{error_count} errors"
      end
    end
  end
end
