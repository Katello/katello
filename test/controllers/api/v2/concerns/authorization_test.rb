# encoding: utf-8

require "katello_test_helper"

module Katello
  class TestBaseController
    def initialize(params, filtered_associations)
      @params = params
      @filtered_associations = filtered_associations
    end

    def self.before_action(*_args)
    end

    include Concerns::Api::V2::Authorization

    attr_accessor :filtered_associations
    attr_reader :params
  end

  class TestAssociationIdController < TestBaseController
    def _wrapper_options
      OpenStruct.new(:name => :content_view)
    end
  end

  class TestPermissionsController < TestBaseController
    def resource_name
      'repository'
    end

    def resource_class
      Repository
    end

    def repository_instance_variable
      @repository
    end

    def path_to_authenticate
      {controller: "katello/api/v2/repositories", action: "index"}
    end

    def load_repositories
      throw_resources_not_found(name: 'repository', expected_ids: params[:ids]) do
        Katello::Repository.where(id: params[:ids])
      end
    end
  end

  class Api::V2::AuthorizationFinderTest < ActiveSupport::TestCase
    def setup
      @repository = katello_repositories(:fedora_17_x86_64)
      @params = {id: @repository.id}
    end

    let(:controller) { TestPermissionsController.new(@params, {}) }

    def test_find_authorized_katello_resource_not_found
      ::Foreman::AccessControl::Permission.any_instance.stubs(:finder_scope).returns(nil)

      assert_raise HttpErrors::NotFound do
        controller.find_authorized_katello_resource
      end
    end

    def test_find_authorized_katello_resource
      controller.find_authorized_katello_resource

      assert_equal @repository, controller.repository_instance_variable
    end

    def test_find_unauthorized_katello_resource
      controller.find_unauthorized_katello_resource

      assert_equal @repository, controller.repository_instance_variable
    end

    def test_throw_resources_not_found
      @params = { ids: [7, 8] }

      assert_raises(HttpErrors::NotFound) do
        controller.load_repositories
      end
    end
  end

  class Api::V2::AuthorizationAssociationTest < ActiveSupport::TestCase
    def setup
      @cv = katello_content_views(:acme_default)
      @repo = katello_repositories(:fedora_17_x86_64)

      @params = {
        content_view: {
          foo: [@cv.id],
          foo2: 3,
          foo3: {
            baz: [@repo.id],
            baz2: 9,
          },
        },
      }

      @filtered_associations = {
        foo: ::Katello::ContentView,
        foo3: {
          baz: ::Katello::Repository,
        },
      }
    end

    let(:controller) { TestAssociationIdController.new(@params, @filtered_associations) }

    def test_find_param_arrays
      assert_equal [[:content_view, :foo], [:content_view, :foo3, :baz]].sort, controller.find_param_arrays.sort
    end

    def test_check_association_ids_positive
      controller.check_association_ids
    end

    def test_check_association_ids_not_found_id
      @params[:content_view][:foo] << -1

      assert_raises(Katello::HttpErrors::NotFound) do
        controller.check_association_ids
      end
    end

    def test_check_association_ids_not_defined
      @params[:content_view][:not_defined] = [1]

      assert_raises(StandardError) do
        controller.check_association_ids
      end
    end
  end
end
