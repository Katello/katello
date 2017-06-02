if Katello.with_remote_execution?
  User.as_anonymous_admin do
    JobTemplate.without_auditing do
      Dir[File.join("#{Katello::Engine.root}/app/views/foreman/job_templates/**/*.erb")].each do |template|
        sync = !Rails.env.test? && Setting[:remote_execution_sync_templates]
        # import! was renamed to import_raw! around 1.3.1
        if JobTemplate.respond_to?('import_raw!')
          JobTemplate.import_raw!(File.read(template), :default => true, :locked => true, :update => sync)
        else
          JobTemplate.import!(File.read(template), :default => true, :locked => true, :update => sync)
        end
      end
    end
  end
end
