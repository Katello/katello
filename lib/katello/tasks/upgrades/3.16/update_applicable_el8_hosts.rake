namespace :katello do
  namespace :upgrades do
    namespace '3.16' do
      desc <<-DESCRIPTION
      Update the applicability calculations for Rhel8 hosts.
      This migration is to be run to address -> https://bugzilla.redhat.com/show_bug.cgi?id=1814095
      DESCRIPTION
      task :update_applicable_el8_hosts, [:input_file] => ["environment"] do
        User.current = User.anonymous_api_admin

        # Find me only those hosts that follow ALL the conditions below
        # 1) Have a module stream enabled.
        # 2) Bound to Non Library repositories. (i.e must belong to a CV thats not the default)
        # 3) Bound repositories must have module streams in them
        hosts = Host.joins(:content_facet => :content_facet_repositories).
                 where("#{Host.table_name}.id" => ::Katello::HostAvailableModuleStream.enabled.select(:host_id)).
                 where("#{Katello::ContentFacetRepository.table_name}.repository_id" =>
                        ::Katello::Repository.joins(:repository_module_streams).
                                          in_non_default_view.
                                          non_archived)
        hosts.each do |host|
          available_streams = ::Katello::HostAvailableModuleStream.joins(:available_module_stream).
                                                enabled.where(:host_id => host).select(:name, :stream)
          ::Actions::Katello::Host::UploadProfiles.upload_modules_to_pulp(available_streams, host)
        end
      end
    end
  end
end
