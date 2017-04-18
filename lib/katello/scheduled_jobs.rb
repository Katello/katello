# First, we check if there's a job already enqueued for Pulp notifications
::Foreman::Application.dynflow.config.on_init do |world|
  pending_jobs = world.persistence.find_execution_plans(filters: { :state => 'scheduled' })
  scheduled_job = pending_jobs.select do |job|
    delayed_plan = world.persistence.load_delayed_plan job.id
    next if delayed_plan.blank?
    delayed_plan.to_hash[:serialized_args].first["job_class"] == 'CreatePulpDiskSpaceNotifications'
  end

  # Only create notifications if there isn't a scheduled job
  CreatePulpDiskSpaceNotifications.perform_later if scheduled_job.blank?
end
