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
describe Api::V1::ContentUploadsController do

  def before_suite
    models = ["Organization", "LifecycleEnvironment", "Repository", "Product", "Provider", "Package"]
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models)
  end

  def setup
    setup_controller_defaults_api
    @repo = Repository.find(katello_repositories(:fedora_17_x86_64))
    @org = get_organization
    @environment = katello_environments(:library)
    login_user(User.find(users(:admin)))

    @edit_permission = UserPermission.new(:update, :providers)
    @read_permission = UserPermission.new(:read, :providers)
  end

  describe "create" do
    let(:action) { :create }

    it "should be protected" do
      req = lambda { post action, :repository_id => @repo.id }
      assert_authorized(permission: @edit_permission, request: req, action: action)
      refute_authorized(permission: [@read_permission, NO_PERMISSION], request: req, action: action)
    end

    it "should create an upload request" do
      mock_pulp_server(:create_upload_request => [])
      post action, :repository_id => @repo.id
      assert_response :success
    end
  end

  describe "upload_bits" do
    let(:action) { :upload_bits }

    it "should be protected" do
      req = lambda { put action, :id => "1" , :offset => "0", :content => "/tmp/my_file.rpm",
                         :repository_id => @repo.id }
      assert_authorized(permission: @edit_permission, request: req, action: action)
      refute_authorized(permission: [@read_permission, NO_PERMISSION], request: req, action: action)
    end

    it "should upload bits" do
      mock_pulp_server(:upload_bits => true)
      put action, :id => "1" , :offset => "0", :content => "/tmp/my_file.rpm",
          :repository_id => @repo.id
      assert_response :success
    end
  end

  describe "import_into_repo" do
    let(:action) { :import_into_repo }

    it "should be protected" do
      req = lambda { post action, :id => "1" , :unit_type_id => "rpm", :unit_key => {}, :unit_metadata => {},
                          :repository_id => @repo.id }
      assert_authorized(permission: @edit_permission, request: req, action: action)
      refute_authorized(permission: [@read_permission, NO_PERMISSION], request: req, action: action)
    end

    it "should import into repository" do
      mock_pulp_server(:import_into_repo => true)
      Repository.any_instance.expects(:trigger_contents_changed).returns([])
      Repository.any_instance.expects(:unit_type_id).returns("rpm")

      post action, :id => "1", :repository_id => @repo.id,
           :uploads => [{:unit_type_id => "rpm", :unit_key => {}, :unit_metadata => {}}]
      assert_response :success
    end
  end

  describe "destroy" do
    let(:action) { :destroy }

    it "should be protected" do
      req = lambda { delete action, :id => "1", :repository_id => @repo.id }
      assert_authorized(permission: @edit_permission, request: req, action: action)
      refute_authorized(permission: [@read_permission, NO_PERMISSION], request: req, action: action)
    end

    it "should delete the request" do
      mock_pulp_server(:delete_upload_request  => true)
      delete action, :id => "1", :repository_id => @repo.id
      assert_response :success
    end
  end

  describe "upload file" do
    let(:action) { :upload_file }

    it "should be protected" do
      req = lambda { post action, :repository_id => @repo.id }
      assert_authorized(permission: @edit_permission, request: req, action: action)
      refute_authorized(permission: [@read_permission, NO_PERMISSION], request: req, action: action)
    end

    it "should upload a file" do
      test_document = File.join(Engine.root, "test", "fixtures", "files", "puppet_module.tar.gz")
      puppet_module = Rack::Test::UploadedFile.new(test_document, '')
      Repository.any_instance.stubs(:upload_content)

      post action, :id => "1", :repository_id => @repo.id, :content => [puppet_module]

      assert_response :success
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
