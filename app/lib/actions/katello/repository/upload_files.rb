# rubocop:disable Lint/SuppressedException
require 'fileutils'
require 'English'

module Actions
  module Katello
    module Repository
      class UploadFiles < Actions::EntryAction
        include Helpers::RollingCVRepos

        def plan(repository, files, content_type = nil, options = {})
          action_subject(repository)
          repository.check_ready_to_act!
          repository.clear_smart_proxy_sync_histories
          tmp_files = prepare_tmp_files(files)

          content_type ||= ::Katello::RepositoryTypeManager.find(repository.content_type).default_managed_content_type.label
          ::Katello::RepositoryTypeManager.check_content_matches_repo_type!(repository, content_type)

          if ::Katello::RepositoryTypeManager.generic_content_type?(content_type)
            unit_type_id = content_type
          else
            unit_type_id = SmartProxy.pulp_primary.content_service(content_type)::CONTENT_TYPE
          end

          upload_actions = []

          generate_applicability = options.fetch(:generate_applicability, repository.yum?)

          sequence do
            tmp_files.each do |file|
              sequence do
                upload_action = plan_action(Pulp3::Orchestration::Repository::UploadContent,
                                                 repository, SmartProxy.pulp_primary!, file, unit_type_id)

                upload_actions << upload_action.output
              end
            end

            plan_action(FinishUpload, repository, content_type: content_type, upload_actions: upload_actions)
            plan_self(tmp_files: tmp_files)
            plan_action(Actions::Katello::Applicability::Repository::Regenerate, :repo_ids => [repository.id]) if generate_applicability

            # Refresh rolling CVs that have this repository
            update_rolling_content_views(repository)
          end
        ensure
          # Delete tmp files when some exception occurred. Would be
          # nice to have other ways to do that: https://github.com/Dynflow/dynflow/issues/130
          delete_tmp_files(tmp_files) if $ERROR_INFO && tmp_files
        end

        def run
          repository = ::Katello::Repository.find(input[:repository][:id])
          ForemanTasks.async_task(Repository::CapsuleSync, repository) if Setting[:foreman_proxy_content_auto_sync]
        rescue ::Katello::Errors::CapsuleCannotBeReached # skip any capsules that cannot be connected to
        end

        def humanized_name
          _("Upload into")
        end

        def finalize
          delete_tmp_files(input[:tmp_files])
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        private

        def tmp_dir
          File.join(Rails.root, 'tmp', 'uploads').tap do |tmp_dir|
            FileUtils.mkdir_p(tmp_dir) unless File.exist?(tmp_dir)
          end
        end

        def prepare_tmp_files(files)
          files.each do |file|
            tmp_file = File.join(tmp_dir, File.basename(file[:path]))
            FileUtils.copy(file[:path], tmp_file)
            file[:path] = tmp_file
          end
        end

        def delete_tmp_files(files)
          files.each { |file| File.delete(file[:path]) }
        end

        def unit_key(file, repository)
          return {} unless repository.file?
          {
            :checksum => Digest::SHA256.hexdigest(File.read(file[:path])),
            :name => file[:filename],
            :size => File.size(file[:path]),
          }
        end
      end
    end
  end
end
