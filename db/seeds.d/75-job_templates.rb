if Katello.with_remote_execution?
  User.as_anonymous_admin do
    JobTemplate.without_auditing do
      template_files = Dir[File.join("#{Katello::Engine.root}/app/views/foreman/job_templates/**/*.erb")]
      template_files.reject! { |file| file.end_with?('_ansible_default.erb') } unless Katello.with_ansible?
      template_files.each do |template|
        sync = !Rails.env.test? && Setting[:remote_execution_sync_templates]
        # import! was renamed to import_raw! around 1.3.1
        if JobTemplate.respond_to?('import_raw!')
          template = JobTemplate.import_raw!(File.read(template), :default => true, :locked => true, :update => sync)
        else
          template = JobTemplate.import!(File.read(template), :default => true, :locked => true, :update => sync)
        end

        template.organizations << Organization.unscoped.all if template&.organizations&.empty?
        template.locations << Location.unscoped.all if template&.locations&.empty?
      end
    end
  end
end
