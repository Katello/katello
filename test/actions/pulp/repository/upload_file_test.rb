require 'katello_test_helper'
require_relative 'test_base.rb'

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
                  unit_key: {},
                  upload_id: upload_request.output[:upload_id])
      run_action(::Actions::Pulp::Repository::DeleteUploadRequest,
                  upload_id: upload_request.output[:upload_id])

      assert_equal 1, repo.pulp_puppet_module_ids.length
    end
  end
end
