require 'fileutils'
require 'English'

module Actions
  module Katello
    module Repository
      class UploadFiles < Actions::EntryAction
        def plan(repository, files)
          action_subject(repository)
          tmp_files = prepare_tmp_files(files)
          sequence do
            concurrence do
              tmp_files.each do |file|
                sequence do
                  upload_request = plan_action(Pulp::Repository::CreateUploadRequest)
                  plan_action(Pulp::Repository::UploadFile,
                              upload_id: upload_request.output[:upload_id],
                              file: file[:path])
                  plan_action(Pulp::Repository::ImportUpload,
                              pulp_id: repository.pulp_id,
                              unit_type_id: repository.unit_type_id,
                              unit_key: unit_key(file, repository),
                              upload_id: upload_request.output[:upload_id])
                  plan_action(Pulp::Repository::DeleteUploadRequest,
                              upload_id: upload_request.output[:upload_id])
                end
              end
            end
            plan_action(FinishUpload, repository)
            plan_self(tmp_files: tmp_files)
          end
        ensure
          # Delete tmp files when some exception occurred. Would be
          # nice to have other ways to do that: https://github.com/Dynflow/dynflow/issues/130
          delete_tmp_files(tmp_files) if $ERROR_INFO && tmp_files
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
