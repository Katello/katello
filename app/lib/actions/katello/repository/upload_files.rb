# rubocop:disable Lint/SuppressedException
require 'English'
require 'fileutils'

module Actions
  module Katello
    module Repository
      class UploadFiles < Actions::EntryAction
        include Helpers::RollingCVRepos
        include Helpers::SmartProxySyncHelper

        def plan(repository, files, content_type = nil, options = {})
          action_subject(repository)
          repository.check_ready_to_act!
          content_type ||= ::Katello::RepositoryTypeManager.find(repository.content_type).default_managed_content_type.label
          ::Katello::RepositoryTypeManager.check_content_matches_repo_type!(repository, content_type)

          if ::Katello::RepositoryTypeManager.generic_content_type?(content_type)
            unit_type_id = content_type
          else
            unit_type_id = SmartProxy.pulp_primary.content_service(content_type)::CONTENT_TYPE
          end

          repository.clear_smart_proxy_sync_histories
          staged_files = stage_files(files, repository)

          upload_actions = []

          generate_applicability = options.fetch(:generate_applicability, repository.yum?)

          sequence do
            staged_files.each do |file|
              sequence do
                upload_action = plan_action(Pulp3::Orchestration::Repository::UploadContent,
                                                 repository, SmartProxy.pulp_primary!, file, unit_type_id)

                upload_actions << upload_action.output
              end
            end

            plan_action(FinishUpload, repository, content_type: content_type, upload_actions: upload_actions)
            plan_self(staged_files: staged_files)
            plan_action(Actions::Katello::Applicability::Repository::Regenerate, :repo_ids => [repository.id]) if generate_applicability

            # Refresh rolling CVs that have this repository
            update_rolling_content_views(repository)
          end
        ensure
          # Delete staged files when some exception occurred. Would be
          # nice to have other ways to do that: https://github.com/Dynflow/dynflow/issues/130
          purge_staged_files(staged_files) if $ERROR_INFO && staged_files
        end

        def run
          repository = ::Katello::Repository.find(input[:repository][:id])
          schedule_async_repository_proxy_sync(repository)
        rescue ::Katello::Errors::CapsuleCannotBeReached # skip any capsules that cannot be connected to
        end

        def humanized_name
          _("Upload into")
        end

        def finalize
          purge_staged_files(input[:staged_files] || input[:tmp_files])
          if ::Katello::UploadStaging.supported?
            # Also recover copies created before a crash while planning, before
            # their IDs could be serialized into the root action input.
            ::Katello::UploadStaging.where(execution_plan_uuid: execution_plan_id, legacy_path: nil).find_each(&:purge!)
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        private

        def stage_files(files, repository)
          staged_files = []
          files.each do |file|
            if ::Katello::UploadStaging.supported?
              staging = ::Katello::UploadStaging.store!(file[:path], repository: repository,
                execution_plan_uuid: execution_plan_id, filename: file[:filename])
              staged_files << staging.metadata
            else
              FileUtils.mkdir_p(::Katello::UploadStaging.legacy_root)
              path = File.join(::Katello::UploadStaging.legacy_root, File.basename(file[:path]))
              FileUtils.cp(file[:path], path)
              staged_files << file.merge(path: path)
            end
          end
          staged_files
        rescue
          purge_staged_files(staged_files)
          raise
        end

        def purge_staged_files(files)
          Array(files).each do |file|
            file = file.with_indifferent_access
            if ::Katello::UploadStaging.supported?
              # Never resolve an arbitrary blob ID: staging belongs to this plan.
              scope = ::Katello::UploadStaging.where(execution_plan_uuid: execution_plan_id)
              scope = scope.where(repository_id: input[:repository][:id]) if input[:repository]
              staging = file[:staging_id] ? scope.find_by(id: file[:staging_id]) : scope.find_by(legacy_path: File.expand_path(file[:path]))
              if staging
                staging.legacy_path ? staging.update!(finished_at: Time.current) : staging.purge!
                next
              end
            end
            if file[:path].present? && File.exist?(file[:path])
              path = File.expand_path(file[:path])
              fail 'Refusing to remove a file outside Katello upload staging' unless File.dirname(path) == ::Katello::UploadStaging.legacy_root && !File.symlink?(path)

              File.delete(path)
            end
          end
        end

        def unit_key(file, repository)
          return {} unless repository.file?
          {
            :checksum => file[:sha256] || Digest::SHA256.file(file[:path]).hexdigest,
            :name => file[:filename],
            :size => file[:byte_size] || File.size(file[:path]),
          }
        end
      end
    end
  end
end
