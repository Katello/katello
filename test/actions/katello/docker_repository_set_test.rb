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

module ::Actions::Katello::RepositorySet
  class DockerTestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before do
      disable_lazy_accessors
      get_organization(:empty_organization)
      product.stubs(:cdn_resource => cdn_resource)
      ::Katello::Product.stubs(:find).with(product.id).returns(product)
    end

    let(:options) do
      {:registry_name => registry_name}
    end
    let(:cdn_resource) do
      ::Katello::Resources::CDN::CdnResource.new(content_url).tap do |cdn_resource|
        cdn_resource.stubs(:get).with(File.join(content_url,
                                                  Katello::Resources::CDN::CdnResource::
                                                  CDN_DOCKER_CONTAINER_LISTING)).returns(registry.to_json)
      end
    end

    let(:content_url) { '/content/dist/rhel/server/7/7Server/x86_64/containers' }

    let(:action) { create_action action_class }
    let(:product) { katello_products(:redhat) }

    let(:content) do
      ::Katello::Candlepin::Content.new(id: 'docker-content-123',
                                        name: 'Docker Content 123',
                                        type: 'containerimage',
                                        label: 'content-123',
                                        contentUrl: content_url)
    end

    let(:registry_name) do
      "dream-registry"
    end
    let(:registry_feed_url) do
      "test.com:5000"
    end
    let(:registry) do
      {
        "header" => {
          "version" => "1.0"
        },
        "payload" => {
          "registries" => [
            { "name" => registry_name,
              "url" => "#{registry_feed_url}/rhel"
            }
          ]
        }
      }
    end

    let(:expected_pulp_id) { "empty_organization-redhat_label-docker_content_123-#{registry_name}".downcase }
    let(:expected_relative_path) { "Empty_Organization/library_label/product/x86_64/6Server" }

    def repository_already_enabled!
      katello_repositories(:rhel_6_x86_64).
          update_attributes!(relative_path: "#{expected_relative_path}",
                             pulp_id: expected_pulp_id,
                             docker_upstream_name: registry_name)
    end
  end

  class DockerScanCdnTest < DockerTestBase
    include Support::Actions::RemoteAction

    let(:action_class) { ::Actions::Katello::RepositorySet::ScanCdn }

    before do
      product.stubs(product_content_by_id: stub(content: content))
      stub_remote_user
    end

    it 'plans' do
      plan_action action, product, content.id
      assert_run_phase action do
        action.input[:product_id].must_equal product.id
        action.input[:content_id].must_equal content.id
      end
    end

    it 'runs' do
      action = simulate_run
      action.output.must_equal("results" =>
                                 [{ "substitutions" => {},
                                    "path" => "https://#{registry_feed_url}",
                                    "repo_name" => "#{content.name} - (#{registry_name})",
                                    "pulp_id" => expected_pulp_id,
                                    "registry_name" => "dream-registry",
                                    "enabled" => false,
                                    "promoted" => false}])
    end

    it 'considers the repo being enabled when the repository object is present' do
      repository_already_enabled!
      action = simulate_run
      action.output[:results].first[:enabled].must_equal true
    end

    def simulate_run
      planned_action = plan_action action, product, content.id
      run_action planned_action do |run_action|
        run_action.stubs(content: content)
      end
    end
  end

  class EnableDockerRepositoryTest < DockerTestBase
    let(:action_class) { ::Actions::Katello::RepositorySet::EnableRepository }

    it 'plans' do
      action.expects(:action_subject).with do |repository|
        repository.pulp_id.must_equal expected_pulp_id
        repository.docker_upstream_name.must_equal registry_name
        repository.url.must_equal "https://#{registry_feed_url}"
      end
      plan_action action, product, content, options
      assert_action_planed action, ::Actions::Katello::Repository::Create
    end

    it 'fails when repository already enabled' do
      repository_already_enabled!
      failed = lambda do
        plan_action(action, product, content, options)
      end
      failed.must_raise(::Katello::Errors::ConflictException)
    end
  end

  class DisableDockerRepositoryTest < DockerTestBase
    let(:action_class) { ::Actions::Katello::RepositorySet::DisableRepository }

    it 'plans' do
      repository_already_enabled!

      action.expects(:action_subject).with do |repository|
        repository.pulp_id.must_equal expected_pulp_id
        repository.docker_upstream_name.must_equal registry_name
      end
      plan_action action, product, content, options
      assert_action_planed action, ::Actions::Katello::Repository::Destroy
    end

    it 'fails when repository not enabled' do
      failed = lambda do
        plan_action(action, product, content, options)
      end
      failed.must_raise(::Katello::Errors::NotFound)
    end
  end
end
