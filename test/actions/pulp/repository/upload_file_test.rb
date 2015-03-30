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

require 'katello_test_helper'

module ::Actions::Pulp::Repository
  class UploadFileTest < VCRTestBase
    let(:repo) { katello_repositories(:p_forge) }
    let(:file) { File.join(Katello::Engine.root, "test/fixtures/puppet/puppetlabs-ntp-2.0.1.tar.gz") }

    def test_upload_file
      upload_request = run_action(::Actions::Pulp::Repository::CreateUploadRequest)
      run_action(::Actions::Pulp::Repository::UploadFile,
                  upload_id: upload_request.output[:upload_id],
                  file: file)
      run_action(::Actions::Pulp::Repository::ImportUpload,
                  pulp_id: repo.pulp_id,
                  unit_type_id: repo.unit_type_id,
                  upload_id: upload_request.output[:upload_id])
      run_action(::Actions::Pulp::Repository::DeleteUploadRequest,
                  upload_id: upload_request.output[:upload_id])

      assert_includes repo.puppet_modules.map(&:name), "ntp"
    end
  end
end
