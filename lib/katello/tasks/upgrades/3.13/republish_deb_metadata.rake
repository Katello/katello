namespace :katello do
  namespace :upgrades do
    namespace '3.13' do
      desc "Regenerate the metadata for repositories affected by pulp_deb migration 0004"
      task :republish_deb_metadata, [:input_file] => ["environment"] do |task, args|
        User.current = User.anonymous_api_admin
        input_file = args[:input_file] || "/var/lib/pulp/0004_deb_repo_republish_candidates.txt"
        if File.readable?(input_file)
          pulp_ids = File.read(input_file).each_line.map(&:strip) || []
          repos = Katello::Repository.where(:pulp_id => pulp_ids)
          puts _("Starting BulkMetadataGenerate task.")
          task = ForemanTasks.async_task(Actions::Katello::Repository::BulkMetadataGenerate, repos, :force => true)
          puts _("Please check that the task #{task.id} completes successfully.")
          puts _('You can manually re-trigger this task by running "foreman-rake katello:upgrades:3.13:republish_deb_metadata"')
        else
          puts _("Input file #{input_file} was not readable.")
          puts _('You can manually use an alternate input file by running "foreman-rake katello:upgrades:3.13:republish_deb_metadata[<path>]"')
        end
      end
    end
  end
end
