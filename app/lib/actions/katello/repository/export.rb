module Actions
  module Katello
    module Repository
      class Export < Actions::EntryAction
        input_format do
          param :id, Integer
          param :export_result, Hash
        end

        EXPORT_OUTPUT_BASEDIR = "/var/lib/pulp/published/yum/master/group_export_distributor/".freeze

        def plan(repos, export_to_iso, since, iso_size, group_id)
          unless File.directory?(Setting['pulp_export_destination'])
            fail ::Foreman::Exception, N_("Unable to export, 'pulp_export_destination' setting is not set to a valid directory.")
          end

          unless File.writable?(Setting['pulp_export_destination'])
            fail ::Foreman::Exception, N_("Unable to export. 'pulp_export_destination' setting is not a writable directory.")
          end

          repo_pulp_ids = repos.collect do |repo|
            action_subject(repo)
            repo.pulp_id
          end

          start_date = since ? since.iso8601 : nil
          unless since.nil?
            group_id += "-incremental"
          end

          # create an export path that's the same as the ISO export path. Pulp
          # only uses this when exporting to a directory, but we want to keep
          # things as similar as possible.
          # Additionally, we want Pulp to export to dirs that Pulp owns, and
          # then Katello can copy it over as needed. This is needed for SELinux
          # reasons.
          export_directory = File.join(EXPORT_OUTPUT_BASEDIR, group_id)

          sequence do
            copy_units(repos)
            plan_action(Pulp::RepositoryGroup::Create, :id => group_id,
                                                       :pulp_ids => repo_pulp_ids)
            plan_action(Pulp::RepositoryGroup::Export, :id => group_id,
                                                       :export_to_iso => export_to_iso,
                                                       :iso_size => iso_size,
                                                       :start_date => start_date,
                                                       :export_directory => export_directory)
            plan_self(:group_id => group_id, :export_to_iso => export_to_iso)
            # NB: the delete will also make Pulp delete our exported data under /var/lib/pulp
            plan_action(Pulp::RepositoryGroup::Delete, :id => group_id)
          end
        end

        def run
          # copy the export to a place we have permission to write to. We let
          # Pulp do the deletion as part of repo group delete since it's under
          # /v/l/p.
          export_location = File.join(EXPORT_OUTPUT_BASEDIR, input[:group_id])
          FileUtils.cp_r(export_location, Setting['pulp_export_destination'], :remove_destination => true)
        end

        def humanized_name
          _("Export")
        end

        def copy_units(repos)
          concurrence do
            repos.each do |repo|
              sequence do
                if repo.link?
                  plan_action(Pulp::Repository::Clear, repo, SmartProxy.pulp_master!)
                  plan_action(Pulp::Repository::CopyAllUnits, repo, ::SmartProxy.pulp_master, repo.target_repository)
                end
              end
            end
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
