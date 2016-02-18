require 'katello_test_helper'

module Katello
  class ContentFacetBase < ActiveSupport::TestCase
    let(:library) { katello_environments(:library) }
    let(:view)  { katello_content_views(:library_dev_view) }
    let(:environment) { katello_environments(:library) }
    let(:empty_host) { ::Host::Managed.create!(:name => 'foobar', :managed => false) }
    let(:host) do
      FactoryGirl.create(:host, :with_content, :content_view => view,
                                     :lifecycle_environment =>  library)
    end
    let(:content_facet) { host.content_facet }
  end

  class ContentFacetTest < ContentFacetBase
    def test_create
      empty_host.content_facet = Katello::Host::ContentFacet.create!(:content_view_id => view.id, :lifecycle_environment_id => library.id, :host => empty_host)
    end

    def test_content_view_version
      assert_equal view.version(library), host.content_facet.content_view_version
    end

    def test_permitted_content_facet_attributes
      assert ::Host.new(:name => "foo", :content_facet_attributes => { :content_view_id => view.id, :lifecycle_environment_id => environment.id })
    end

    def test_protected_content_facet_attributes
      assert_raises ActiveModel::MassAssignmentSecurity::Error do
        assert ::Host.new(:name => "foo", :content_facet_attributes => {:uuid => "thisshouldntbeabletobesetbyuser"})
      end
    end
  end

  class ContentFacetErrataTest < ContentFacetBase
    let(:host) { hosts(:one) }

    def test_applicable_errata
      refute_empty content_facet.applicable_errata
    end

    def test_available_and_applicable_errta
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64))
      content_facet.bound_repositories = [@view_repo]
      content_facet.save!
      assert_equal_arrays content_facet.applicable_errata, content_facet.installable_errata
    end

    def test_installable_errata
      lib_applicable = content_facet.applicable_errata

      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1))
      content_facet.bound_repositories = [@view_repo]
      content_facet.save!

      assert_equal_arrays lib_applicable, content_facet.applicable_errata
      refute_equal_arrays lib_applicable, content_facet.installable_errata
      assert_includes content_facet.installable_errata, Erratum.find(katello_errata(:security))
    end

    def test_with_installable_errata
      content_facet.bound_repositories = [Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1))]
      content_facet.save!

      content_facet_dev = katello_content_facets(:two)
      content_facet_dev.bound_repositories = [Katello::Repository.find(katello_repositories(:fedora_17_x86_64_dev))]
      content_facet_dev.save!

      installable = content_facet_dev.applicable_errata & content_facet_dev.installable_errata
      non_installable = content_facet_dev.applicable_errata - content_facet_dev.installable_errata

      refute_empty non_installable
      refute_empty installable
      content_facets = Katello::Host::ContentFacet.with_installable_errata([installable.first])
      assert_includes content_facets, content_facet_dev

      content_facets = Katello::Host::ContentFacet.with_installable_errata([non_installable.first])
      refute content_facets.include?(content_facet_dev)

      content_facets = Katello::Host::ContentFacet.with_installable_errata([installable.first, non_installable.first])
      refute content_facets.include?(content_facet_dev)
    end

    def test_with_non_installable_errata
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1))
      content_facet.bound_repositories = [@view_repo]
      content_facet.save!

      unavailable = content_facet.applicable_errata - content_facet.installable_errata
      refute_empty unavailable
      content_facets = Katello::Host::ContentFacet.with_non_installable_errata([unavailable.first])
      assert_includes content_facets, content_facet

      content_facets = Katello::Host::ContentFacet.with_non_installable_errata([content_facet.installable_errata.first])
      refute content_facets.include?(content_facet)
    end

    def test_available_errata_other_view
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1))
      content_facet.bound_repositories = [@view_repo]
      content_facet.save!

      available_in_view = content_facet.installable_errata(@library, @library_view)
      assert_equal 1, available_in_view.length
      assert_includes available_in_view, Erratum.find(katello_errata(:security))
    end
  end

  class ImportApplicabilityTest < ContentFacetBase
    let(:enhancement_errata) { katello_errata(:enhancement) }

    def test_partial_import
      refute_includes host.content_facet.applicable_errata, enhancement_errata

      ::Katello::Pulp::Consumer.any_instance.stubs(:applicable_errata_ids).returns([enhancement_errata.uuid])
      content_facet.import_applicability(true)

      assert_equal [enhancement_errata], content_facet.reload.applicable_errata
    end

    def test_partial_import_empty
      content_facet.applicable_errata << enhancement_errata

      ::Katello::Pulp::Consumer.any_instance.stubs(:applicable_errata_ids).returns([])
      content_facet.import_applicability(true)

      assert_empty content_facet.reload.applicable_errata
    end

    def test_full_import
      ::Katello::Pulp::Consumer.any_instance.stubs(:applicable_errata_ids).returns([enhancement_errata.uuid])
      content_facet.import_applicability(false)

      assert_equal [enhancement_errata], content_facet.reload.applicable_errata
    end
  end

  class BoundReposTest < ContentFacetBase
    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:view_repo) { katello_repositories(:fedora_17_x86_64_library_view_1) }

    def test_save_bound_repos_by_path_empty
      ForemanTasks.expects(:async_task).with(Actions::Katello::Host::GenerateApplicability, [host])
      content_facet.expects(:propagate_yum_repos)
      content_facet.bound_repositories << repo

      content_facet.update_repositories_by_paths([])

      assert_empty content_facet.bound_repositories
    end

    def test_save_bound_repos_by_paths
      content_facet.content_view = repo.content_view
      content_facet.lifecycle_environment = repo.environment
      ForemanTasks.expects(:async_task).with(Actions::Katello::Host::GenerateApplicability, [host])
      content_facet.expects(:propagate_yum_repos)
      assert_empty content_facet.bound_repositories

      content_facet.update_repositories_by_paths(["/pulp/repos/#{repo.relative_path}"])

      assert_equal content_facet.bound_repositories, [repo]
    end

    def test_propagate_yum_repos
      content_facet.bound_repositories << repo
      ::Katello::Pulp::Consumer.any_instance.expects(:bind_yum_repositories).with([repo.pulp_id])
      content_facet.propagate_yum_repos
    end

    def test_propagate_yum_repos_non_library
      content_facet.bound_repositories << view_repo
      ::Katello::Pulp::Consumer.any_instance.expects(:bind_yum_repositories).with([view_repo.library_instance.pulp_id])
      content_facet.propagate_yum_repos
    end
  end

  class ContentHostExtensions < ContentFacetBase
    def setup
      assert host #force lazy load
    end

    def test_content_view_search
      assert_includes ::Host::Managed.search_for("content_view = \"#{view.name}\""), host
    end

    def test_lifecycle_environment_search
      assert_includes ::Host::Managed.search_for("lifecycle_environment = #{library.name}"), host
    end

    def test_errata_status_search
      status = host.get_status(Katello::ErrataStatus)
      status.status = Katello::ErrataStatus::NEEDED_ERRATA
      status.reported_at = DateTime.now
      status.save!

      assert_includes ::Host::Managed.search_for("errata_status = errata_needed"), content_facet.host
    end
  end
end
