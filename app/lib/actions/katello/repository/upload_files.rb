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

module Actions
  module Katello
    module Repository
      class UploadFiles < Actions::EntryAction

        def plan(repository, files)
          action_subject(repository)
          sequence do
            concurrence do
              files.each do |file|
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
          end

        end

        def humanized_name
          _("Upload into")
        end

      end
    end
  end
end
