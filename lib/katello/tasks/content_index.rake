require File.expand_path("../engine", File.dirname(__FILE__))

interned_associations = [
  ['katello_repository_rpms', 'katello_content_index_rpms', 'rpm_id', []],
  ['katello_repository_errata', 'katello_content_index_errata', 'erratum_id', %w[erratum_pulp3_href erratum_prn]],
  ['katello_repository_srpms', 'katello_content_index_srpms', 'srpm_id', []],
  ['katello_repository_module_streams', 'katello_content_index_module_streams', 'module_stream_id', []],
  ['katello_repository_debs', 'katello_content_index_debs', 'deb_id', []],
  ['katello_repository_file_units', 'katello_content_index_file_units', 'file_unit_id', []],
  ['katello_repository_package_groups', 'katello_content_index_package_groups', 'package_group_id', []],
  ['katello_repository_ansible_collections', 'katello_content_index_ansible_collections', 'ansible_collection_id', []],
  ['katello_repository_generic_content_units', 'katello_content_index_generic_content_units', 'generic_content_unit_id', []],
].freeze

namespace :katello do
  namespace :content_index do
    desc "Point repositories at a content index built from their Pulp version"
    task :backfill => :environment do
      connection = ActiveRecord::Base.connection
      repositories = ::Katello::Repository.where(:content_index_id => nil).where.not(:version_href => nil).
                     pluck(:id, :version_href)

      puts "backfilling #{repositories.map(&:last).uniq.size} content indexes for #{repositories.size} repositories"
      repositories.group_by(&:last).each do |version_href, rows|
        repo_ids = rows.map(&:first)
        index = ::Katello::ContentIndex.for_version(version_href)

        interned_associations.each do |repository_table, index_table, unit_field, extra_columns|
          columns = ['content_index_id', unit_field] + extra_columns + %w[created_at updated_at]
          values = [index.id.to_s, unit_field] + extra_columns + ['now()', 'now()']
          connection.execute(
            "insert into #{index_table} (#{columns.join(', ')}) " \
            "select distinct #{values.join(', ')} from #{repository_table} " \
            "where repository_id in (#{repo_ids.join(', ')}) on conflict do nothing"
          )
        end

        ::Katello::Repository.where(:id => repo_ids).update_all(:content_index_id => index.id)
      end
    end

    desc "Delete content indexes no repository references"
    task :gc => :environment do
      orphaned = ::Katello::ContentIndex.orphaned
      count = orphaned.count
      orphaned.find_each(&:destroy!)
      puts "deleted #{count} unreferenced content indexes"
    end

    desc "Report content index usage"
    task :stats => :environment do
      puts "content indexes:              #{::Katello::ContentIndex.count}"
      puts "repositories with an index:   #{::Katello::Repository.where.not(:content_index_id => nil).count}"
      puts "repositories without:         #{::Katello::Repository.where(:content_index_id => nil).count}"
      puts "indexes shared by >1 repo:    #{::Katello::ContentIndex.where(:id => ::Katello::Repository.group(:content_index_id).having('count(*) > 1').select(:content_index_id)).count}"
      interned_associations.each do |repository_table, index_table, _unit_field, _extra|
        repository_rows = ActiveRecord::Base.connection.select_value("select count(*) from #{repository_table}").to_i
        index_rows = ActiveRecord::Base.connection.select_value("select count(*) from #{index_table}").to_i
        puts format('%-46s repository rows=%9d index rows=%9d', index_table, repository_rows, index_rows)
      end
    end
  end
end
