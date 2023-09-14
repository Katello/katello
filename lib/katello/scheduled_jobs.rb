# First, we check if there's a job already enqueued for any notifications
::Foreman::Application.dynflow.config.on_init do |world|
  [CreateExpiredManifestNotifications, CreateHostLifecycleExpireSoonNotifications, CreatePulpDiskSpaceNotifications, SendExpireSoonNotifications].each do |job_class|
    job_class.spawn_if_missing(world)
  end
end
