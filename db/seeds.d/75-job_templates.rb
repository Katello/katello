if Katello.with_remote_execution?
  User.as_anonymous_admin do
    JobTemplate.without_auditing do
      Dir[File.join("#{Katello::Engine.root}/app/views/foreman/job_templates/**/*.erb")].each do |template|
        sync = !Rails.env.test? && Setting[:remote_execution_sync_templates]
        JobTemplate.import!(File.read(template), :default => true, :locked => true, :update => sync)
      end
    end
  end
end
