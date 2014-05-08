# encoding: utf-8
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

require "katello_test_helper"

module Katello
  class Api::V2::ContentUploadsControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["Organization", "LifecycleEnvironment", "Repository", "Product", "Provider", "Package"]
      services = ["Candlepin", "Pulp", "ElasticSearch"]
      disable_glue_layers(services, models)
      super
    end

    def models
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64))
      @org = get_organization
      @environment = katello_environments(:library)
    end

    def permissions
      @edit_permission = UserPermission.new(:update, :providers)
      @read_permission = UserPermission.new(:read, :providers)
      @no_permission = NO_PERMISSION
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
      models
      permissions
    end

    def test_create_upload_request
      mock_pulp_server(:create_upload_request => [])
      post :create, :repository_id => @repo.id

      assert_response :success
    end

    def test_create_upload_request_protected
      allowed_perms = [@edit_permission]
      denied_perms = [@read_permission, @no_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, :repository_id => @repo.id
      end
    end

    def test_upload_bits
      mock_pulp_server(:upload_bits => true)
      put :upload_bits, :id => "1" , :offset => "0", :content => "/tmp/my_file.rpm", :repository_id => @repo.id

      assert_response :success
    end

    def test_upload_bits_protected
      allowed_perms = [@edit_permission]
      denied_perms = [@read_permission, @no_permission]

      assert_protected_action(:upload_bits, allowed_perms, denied_perms) do
        put :upload_bits, :id => "1" , :offset => "0", :content => "/tmp/my_file.rpm", :repository_id => @repo.id
      end
    end

    def test_import_into_repo
      mock_pulp_server(:import_into_repo => true)
      Repository.any_instance.expects(:trigger_contents_changed).returns([])
      Repository.any_instance.expects(:unit_type_id).returns("rpm")

      post :import_into_repo, :id => "1", :repository_id => @repo.id,
           :uploads => [{:unit_type_id => "rpm", :unit_key => {}, :unit_metadata => {}}]

      assert_response :success
    end

    def test_import_into_repo_protected
      allowed_perms = [@edit_permission]
      denied_perms = [@read_permission, @no_permission]

      assert_protected_action(:import_into_repo, allowed_perms, denied_perms) do
        post :import_into_repo, :id => "1", :unit_type_id => "rpm", :unit_key => {}, :unit_metadata => {},
             :repository_id => @repo.id
      end
    end

    def test_delete_request
      mock_pulp_server(:delete_upload_request  => true)
      delete :destroy, :id => "1", :repository_id => @repo.id

      assert_response :success
    end

    def test_delete_request_protected
      allowed_perms = [@edit_permission]
      denied_perms = [@no_permission, @read_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, :id => "1", :repository_id => @repo.id
      end
    end

    def test_upload_file
      test_document = File.join(Engine.root, "test", "fixtures", "files", "puppet_module.tar.gz")
      puppet_module = Rack::Test::UploadedFile.new(test_document, '')
      Repository.any_instance.stubs(:upload_content)

      post :upload_file, :id => "1", :repository_id => @repo.id, :content => [puppet_module]

      assert_response :success
    end

    def test_upload_file_protected
      allowed_perms = [@edit_permission]
      denied_perms = [@read_permission, @no_permission]

      assert_protected_action(:upload_file, allowed_perms, denied_perms) do
        post :upload_file, :repository_id => @repo.id
      end
    end

    private

    def mock_pulp_server(content_hash)
      content = mock(content_hash)
      resources = mock(:content => content)
      pulp_server = mock(:resources => resources)
      Katello.expects(:pulp_server).returns(pulp_server)
    end
  end
end
