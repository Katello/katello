namespace :katello do
  desc "This task collates hostgroup content facts that were missed during the upgrade from audit.\
        It then updates the hostgroup content_facet accordingly."
  task :fix_hostgroup_facets => :environment do
    User.current = User.anonymous_admin
    ::Katello::Util::HostgroupFacetsHelper.new.main
  end
end
