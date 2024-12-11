User.as_anonymous_admin do
  JobTemplate.without_auditing do
    # let's name root template as *_action.erb
    root_action_files = Dir[File.join("#{Katello::Engine.root}/app/views/foreman/job_templates/**/*_action.erb")]
    template_files = Dir[File.join("#{Katello::Engine.root}/app/views/foreman/job_templates/**/*.erb")]
    template_files.reject! { |file| file.end_with?('_ansible_default.erb') } unless Katello.with_ansible?

    # root templates need to be imported first
    (root_action_files + (template_files - root_action_files)).each do |template|
      sync = !Rails.env.test? && Setting[:remote_execution_sync_templates]
      template = JobTemplate.import_raw!(File.read(template), :default => true, :lock => true, :update => sync)

      template.organizations << Organization.unscoped.all if template&.organizations&.empty?
      template.locations << Location.unscoped.all if template&.locations&.empty?
    end
  end
end
