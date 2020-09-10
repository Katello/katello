require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
  class UploadFileTest < VCRTestBase
    let(:repo) { katello_repositories(:p_forge) }
    let(:file) { File.join(Katello::Engine.root, "test/fixtures/puppet/puppetlabs-ntp-2.0.1.tar.gz") }
    before do
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
    end

    def test_upload_file
      upload_request = run_action(::Actions::Pulp::Repository::CreateUploadRequest)
      VCR.use_cassette(cassette_name + '_binary', :match_requests_on => [:method, :path, :params, :body]) do
        run_action(::Actions::Pulp::Repository::UploadFile,
                    upload_id: upload_request.output[:upload_id],
                    file: file)
      end

      run_action(::Actions::Pulp::Repository::ImportUpload,
                 repo, SmartProxy.pulp_primary,
                    pulp_id: repo.pulp_id,
                     unit_type_id: repo.unit_type_id,
                     unit_key: {},
                     upload_id: upload_request.output[:upload_id]
                  )

      run_action(::Actions::Pulp::Repository::DeleteUploadRequest,
                  upload_id: upload_request.output[:upload_id])

      assert_equal 1, ::Katello::Pulp::PuppetModule.ids_for_repository(repo.pulp_id).length
    end
  end
end
