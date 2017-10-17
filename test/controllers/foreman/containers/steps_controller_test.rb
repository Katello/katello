require 'katello_test_helper'

module Containers
  class StepsControllerTest < ActionController::TestCase
    def setup
      setup_controller_defaults(false)
      setup_foreman_routes

      login_user(User.find(users(:admin).id))
      @compute_resource = FactoryGirl.create(:docker_stuff)
      @state = DockerContainerWizardState.create!

      @state.preliminary = DockerContainerWizardStates::Preliminary.create do |prelim|
        prelim.wizard_state = @state
        prelim.compute_resource_id = @compute_resource.id
      end

      DockerContainerWizardState.expects(:find).at_least_once.returns(@state)
    end

    def test_show_image_loads_katello
      get :show, :wizard_state_id => @state.id,
                 :id => :image
      assert @state.image.katello?
      # Only match the container.js part - as the response.body will contain
      # something like "digest+container.js" on Sprockets 3.x, even on the
      # test environment
      assert_match(/container.*\.js/, response.body)
      docker_image = @controller.instance_eval do
        @docker_container_wizard_states_image
      end
      assert_equal @state.image, docker_image
    end

    def test_create_image_with_katello
      repo = OpenStruct.new(:id => 100, :container_repository_name => "repo_pulp_id")
      ::Katello::Repository.expects(:where).with(:id => repo.id.to_s).returns([repo])

      tag = OpenStruct.new(:id => 200, :name => "tag_name")
      ::Katello::DockerMetaTag.expects(:where).with(:id => tag.id.to_s).returns([tag])

      capsule_id = 300
      image = OpenStruct.new(:id => 1000)

      @state.expects(:build_image).with(:repository_name => repo.container_repository_name,
                                        :tag => tag.name,
                                        :capsule_id => capsule_id.to_s,
                                        :katello => true,
                                        :katello_content => {
                                          :organization_id => nil,
                                          :environment_id => nil,
                                          :content_view_id => nil,
                                          :repository_id => 100,
                                          :tag_id => 200
                                        }).returns(image)

      put :update, :wizard_state_id => @state.id,
                   :id => :image,
                   :katello => true,
                   :repository => {:id => repo.id},
                   :tag => {:id => tag.id},
                   :capsule => {:id => capsule_id}

      docker_image = @controller.instance_eval do
        @docker_container_wizard_states_image
      end
      assert_equal image, docker_image
    end
  end
end
