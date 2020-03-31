# rubocop:disable Lint/SuppressedException
require 'fileutils'
require 'English'

module Actions
  module Katello
    module Repository
      class UploadFiles < Actions::EntryAction
        include Actions::Katello::PulpSelector
        def plan(repository, files, content_type = nil)
          action_subject(repository)
          tmp_files = prepare_tmp_files(files)

          content_type ||= ::Katello::RepositoryTypeManager.find(repository.content_type).default_managed_content_type.label
          unit_type_id = SmartProxy.pulp_master.content_service(content_type)::CONTENT_TYPE
          upload_actions = []
          uploaded_content_unit_hrefs = []
          sequence do
            concurrence do
              tmp_files.each do |file|
                sequence do
                  upload_action_output = plan_pulp_action([Pulp::Orchestration::Repository::UploadContent,
                                    Pulp3::Orchestration::Repository::UploadContent],
                                                   repository, SmartProxy.pulp_master!, file, unit_type_id).output

                  upload_actions << upload_action_output
                end
              end
            end

            plan_action(FinishUpload, repository, content_type: content_type, upload_actions: upload_actions.compact!)
            plan_self(tmp_files: tmp_files)
          end
        ensure
          # Delete tmp files when some exception occurred. Would be
          # nice to have other ways to do that: https://github.com/Dynflow/dynflow/issues/130
          delete_tmp_files(tmp_files) if $ERROR_INFO && tmp_files
        end

        def run
          ForemanTasks.async_task(Repository::CapsuleSync, ::Katello::Repository.find(input[:repository][:id])) if Setting[:foreman_proxy_content_auto_sync]
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
            :size => File.size(file[:path])
          }
        end
      end
    end
  end
end
