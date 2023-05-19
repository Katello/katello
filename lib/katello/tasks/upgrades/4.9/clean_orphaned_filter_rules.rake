namespace :katello do
  namespace :upgrades do
    namespace '4.9' do
      desc "Clean orphaned filter rules that cause Pulp copy errors during content view publishing"
      task :clean_orphaned_filter_rules => ['environment'] do
        module_stream_count = 0
        erratum_count = 0
        package_group_count = 0

        ::Katello::ContentViewModuleStreamFilterRule.all.each do |rule|
          # Delete if rule exists in a CV that does not have the matching module stream in its repositories
          content_view = rule.filter.content_view
          unless ::Katello::ModuleStream.in_repositories(content_view.repositories)&.pluck(:id)&.include?(rule.module_stream_id)
            rule.delete
            module_stream_count+=1
          end
        end
        puts "#{module_stream_count} orphaned content view module stream filter rules were deleted."

        ::Katello::ContentViewErratumFilterRule.all.each do |rule|
          content_view = rule.filter.content_view
          unless ::Katello::Erratum.in_repositories(content_view.repositories)&.pluck(:errata_id)&.include?(rule.errata_id)
            rule.delete
            erratum_count+=1
          end
        end
        puts "#{erratum_count} orphaned content view erratum filter rules were deleted."

        ::Katello::ContentViewPackageGroupFilterRule.all.each do |rule|
          content_view = rule.filter.content_view
          unless ::Katello::PackageGroup.in_repositories(content_view.repositories)&.pluck(:pulp_id)&.include?(rule.uuid)
            rule.delete
            package_group_count+=1
          end
        end
        puts "#{package_group_count} orphaned content view package group filter rules were deleted."
      end
    end
  end
end
