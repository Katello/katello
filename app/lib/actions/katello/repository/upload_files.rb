#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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
                              file: file)
                  plan_action(Pulp::Repository::ImportUpload,
                              pulp_id: repository.pulp_id,
                              unit_type_id: repository.unit_type_id,
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

        private

        def tmp_dir
          File.join(Rails.root, 'tmp', 'uploads').tap do |tmp_dir|
            FileUtils.mkdir_p(tmp_dir) unless File.exist?(tmp_dir)
          end
        end

        def prepare_tmp_files(files)
          files.map do |file|
            tmp_file = File.join(tmp_dir, File.basename(file))
            FileUtils.copy(file, tmp_file)
            tmp_file
          end
        end

        def delete_tmp_files(files)
          files.each { |file| File.delete(file) }
        end
      end
    end
  end
end
