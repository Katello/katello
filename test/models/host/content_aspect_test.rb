require 'katello_test_helper'

module Katello
  class ContentAspectBase < ActiveSupport::TestCase
    let(:library) { katello_environments(:library) }
    let(:view)  { katello_content_views(:library_dev_view) }
    let(:empty_host) { ::Host::Managed.create!(:name => 'foobar', :managed => false) }
    let(:host) do
      FactoryGirl.create(:host, :with_content, :content_view => view,
                                     :lifecycle_environment =>  library)
    end
    let(:content_aspect) { host.content_aspect }
  end

  class ContentAspectTest < ContentAspectBase
    def test_create
      empty_host.content_aspect = Katello::Host::ContentAspect.create!(:content_view => view, :lifecycle_environment => library, :host => empty_host)
    end
  end

  class ImportApplicabilityTest < ContentAspectBase
    let(:enhancement_errata) { katello_errata(:enhancement) }

    def test_partial_import
      refute_includes host.content_aspect.applicable_errata, enhancement_errata

      ::Katello::Pulp::Consumer.any_instance.stubs(:applicable_errata_ids).returns([enhancement_errata.uuid])
      content_aspect.import_applicability(true)

      assert_equal [enhancement_errata], content_aspect.reload.applicable_errata
    end

    def test_partial_import_empty
      content_aspect.applicable_errata << enhancement_errata

      ::Katello::Pulp::Consumer.any_instance.stubs(:applicable_errata_ids).returns([])
      content_aspect.import_applicability(true)

      assert_empty content_aspect.reload.applicable_errata
    end

    def test_full_import
      ::Katello::Pulp::Consumer.any_instance.stubs(:applicable_errata_ids).returns([enhancement_errata.uuid])
      content_aspect.import_applicability(false)

      assert_equal [enhancement_errata], content_aspect.reload.applicable_errata
    end
  end

  class BoundReposTest < ContentAspectBase
    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:view_repo) { katello_repositories(:fedora_17_x86_64_library_view_1) }

    def test_save_bound_repos_by_path_empty
      ForemanTasks.expects(:async_task).with(Actions::Katello::Host::GenerateApplicability, [host])
      content_aspect.expects(:propagate_yum_repos)
      content_aspect.bound_repositories << repo

      content_aspect.update_repositories_by_paths([])

      assert_empty content_aspect.bound_repositories
    end

    def test_save_bound_repos_by_paths
      content_aspect.content_view = repo.content_view
      content_aspect.lifecycle_environment = repo.environment
      ForemanTasks.expects(:async_task).with(Actions::Katello::Host::GenerateApplicability, [host])
      content_aspect.expects(:propagate_yum_repos)
      assert_empty content_aspect.bound_repositories

      content_aspect.update_repositories_by_paths(["/pulp/repos/#{repo.relative_path}"])

      assert_equal content_aspect.bound_repositories, [repo]
    end

    def test_propagate_yum_repos
      content_aspect.bound_repositories << repo
      ::Katello::Pulp::Consumer.any_instance.expects(:bind_yum_repositories).with([repo.pulp_id])
      content_aspect.propagate_yum_repos
    end

    def test_propagate_yum_repos_non_library
      content_aspect.bound_repositories << view_repo
      ::Katello::Pulp::Consumer.any_instance.expects(:bind_yum_repositories).with([view_repo.library_instance.pulp_id])
      content_aspect.propagate_yum_repos
    end
  end

  class ContentHostExtensions < ContentAspectBase
    def setup
      assert host #force lazy load
    end

    def test_content_view_search
      assert_includes ::Host::Managed.search_for("content_view = \"#{view.name}\""), host
    end

    def test_lifecycle_environment_search
      assert_includes ::Host::Managed.search_for("lifecycle_environment = #{library.name}"), host
    end
  end
end
