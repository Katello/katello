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

  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryGirl::Syntax::Methods

    before do
      disable_lazy_accessors
      get_organization(:empty_organization)
      product.stubs(cdn_resource: cdn_resource)
    end

    let(:cdn_resource) do
      ::Katello::Resources::CDN::CdnResource.new(content_url).tap do |cdn_resource|
         cdn_resource.stubs(:get).returns('x86_64', '6Server')
      end
    end

    let(:content_url) { '/product/$basearch/$releasever' }
    let(:action) { create_action action_class }
    let(:product) { katello_products(:redhat) }
    let(:content) { ::Katello::Candlepin::Content.new(id: 'content-123',
                                                      name: 'Content 123',
                                                      type: 'yum',
                                                      label: 'content-123',
                                                      contentUrl: content_url) }
    let(:substitutions) { { basearch: 'x86_64', releasever: '6Server' } }
    let(:expected_pulp_id) { "Empty_Organization-redhat_label-Content_123_x86_64_6Server" }
    let(:expected_relative_path) { "Empty_Organization/library_label/product/x86_64/6Server" }

    def repository_already_enabled!
      katello_repositories(:rhel_6_x86_64).
          update_attributes!(relative_path: "#{expected_relative_path}",
                               pulp_id: expected_pulp_id)
    end
  end

  class EnableRepositoryTest < TestBase
    let(:action_class) { ::Actions::Katello::RepositorySet::EnableRepository }

    it 'plans' do
      action.expects(:action_subject).with do |repository|
        repository.pulp_id.must_equal expected_pulp_id
        repository.relative_path.must_equal expected_relative_path
      end
      plan_action action, product, content, substitutions
      assert_action_planed action, ::Actions::Katello::Repository::Create
    end

    it 'fails when repository already enabled' do
      action.world.silence_logger!
      repository_already_enabled!
      lambda do
        plan_action(action, product, content, substitutions)
      end.must_raise(::Katello::Errors::ConflictException)
    end
  end

  class DisableRepositoryTest < TestBase
    let(:action_class) { ::Actions::Katello::RepositorySet::DisableRepository }

    it 'plans' do
      repository_already_enabled!

      action.expects(:action_subject).with do |repository|
        repository.pulp_id.must_equal expected_pulp_id
        repository.relative_path.must_equal expected_relative_path
      end
      plan_action action, product, content, substitutions
      assert_action_planed action, ::Actions::Katello::Repository::Destroy
    end

    it 'fails when repository not enabled' do
      action.world.silence_logger!
      lambda do
        plan_action(action, product, content, substitutions)
      end.must_raise(::Katello::Errors::NotFound)
    end
  end

  class ScanCdnTest < TestBase
    include Support::Actions::RemoteAction

    let(:action_class) { ::Actions::Katello::RepositorySet::ScanCdn }

    before do
      product.stubs(product_content_by_id: stub(content: content))
      stub_remote_user
    end

    it 'plans' do
      plan_action action, product, content.id
      assert_run_phase action do |input|
        input[:product_id].must_equal product.id
        input[:content_id].must_equal content.id
      end
    end

    it 'runs' do
      action = simulate_run
      action.output.
          must_equal({ "results" =>
                       [{"substitutions"=>{"basearch"=>"x86_64", "releasever"=>"6Server"},
                          "path"=>"/product/x86_64/6Server",
                          "repo_name"=>"Content 123 x86_64 6Server",
                          "pulp_id"=>"Empty_Organization-redhat_label-Content_123_x86_64_6Server",
                          "enabled"=>false,
                          "promoted"=>false}]})
    end

    it 'considers the repo being enabled when the repository object is present' do
      repository_already_enabled!
      action = simulate_run
      action.output[:results].first[:enabled].must_equal true
    end

    def simulate_run
      planned_action = plan_action action, product, content.id

      run_action planned_action do |run_action|
        substitutor = stub(:cdn_var_substitutor)
        substitutor.stubs(substitute_vars: [substitutions])
        run_action.stubs(content: content)
        run_action.stubs(cdn_var_substitutor: substitutor)
      end
    end

  end

end
