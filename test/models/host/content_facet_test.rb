require 'katello_test_helper'

module Katello
  class ContentFacetBase < ActiveSupport::TestCase
    let(:library) { katello_environments(:library) }
    let(:dev) { katello_environments(:dev) }
    let(:view)  { katello_content_views(:library_dev_view) }
    let(:environment) { katello_environments(:library) }
    let(:empty_host) { ::Host::Managed.create!(:name => 'foobar', :managed => false) }
    let(:host) do
      FactoryBot.create(:host, :with_content, :content_view => view,
                        :lifecycle_environment => library,
                        :operatingsystem => FactoryBot.create(:operatingsystem, :release_name => ''))
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

    def test_katello_agent_installed?
      refute host.content_facet.katello_agent_installed?

      host.installed_packages << Katello::InstalledPackage.create!(:name => 'katello-agent', 'nvrea' => 'katello-agent-1.0.x86_64', 'nvra' => 'katello-agent-1.0.x86_64')

      assert host.reload.content_facet.katello_agent_installed?
    end

    def test_tracer_installed?
      refute host.content_facet.tracer_installed?

      host.installed_packages << Katello::InstalledPackage.create!(:name => 'katello-host-tools-tracer', 'nvrea' => 'katello-host-tools-tracer-1.0.x86_64', 'nvra' => 'katello-agent-1.0.x86_64')

      assert host.reload.content_facet.tracer_installed?
    end

    def test_in_content_view_version_environments
      first_cvve = {:content_view_version => content_facet.content_view.version(content_facet.lifecycle_environment),
                    :environments => [content_facet.lifecycle_environment]}
      second_cvve = {:content_view_version => view.version(library), :environments => [dev]} #dummy set

      facets = Host::ContentFacet.in_content_view_version_environments([first_cvve, second_cvve])
      assert_includes facets, content_facet

      facets = Host::ContentFacet.in_content_view_version_environments([first_cvve])
      assert_includes facets, content_facet
    end

    def test_audit_for_content_facet
      org = taxonomies(:empty_organization)
      host1 = ::Host::Managed.create!(:name => 'foohost', :managed => false, :organization_id => org.id)
      content_facet1 = Katello::Host::ContentFacet.create!(
        :content_view_id => view.id, :lifecycle_environment_id => library.id, :host => host1
      )

      recent_audit = Audit.where(auditable_id: content_facet1.id).last
      assert recent_audit, "No audit record for content_facet"
      assert_equal 'create', recent_audit.action
      assert_includes recent_audit.organization_ids, org.id

      content_facet_rec = host1.associated_audits.where(auditable_id: content_facet1.id)
      assert content_facet_rec, "No associated audit record for content_facet"
    end
  end

  class ContentFacetErrataTest < ContentFacetBase
    let(:host) { hosts(:one) }

    def test_applicable_errata
      refute_empty content_facet.applicable_errata
    end

    def test_errata_searchable
      other_host = FactoryBot.create(:host)
      errata = katello_errata(:security)
      found = ::Host.search_for("applicable_errata = #{errata.errata_id}")

      assert_includes found, content_facet.host
      refute_includes found, other_host
    end

    def test_installable_errata_searchable
      other_host = FactoryBot.create(:host)
      errata = katello_errata(:security)
      found = ::Host.search_for("installable_errata = #{errata.errata_id}")

      refute_includes found, host

      host.content_facet.bound_repositories << errata.repositories.first

      found = ::Host.search_for("installable_errata = #{errata.errata_id}")

      assert_includes found, content_facet.host
      refute_includes found, other_host
    end

    def test_installable_errata_search
      content_facet.bound_repositories = [Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1).id)]
      content_facet.save!

      host_without_errata = hosts(:without_errata)
      host_without_errata.content_facet.bound_repositories = [Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1).id)]
      host_without_errata.content_facet.save!

      errata = katello_errata(:security)
      found = ::Host.search_for("installable_errata = #{errata.errata_id}")

      refute_includes found, host_without_errata
      assert_includes found, content_facet.host
    end

    def test_available_and_applicable_errta
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64).id)
      content_facet.bound_repositories = [@view_repo]
      content_facet.save!
      assert_equal_arrays content_facet.applicable_errata, content_facet.installable_errata
    end

    def test_installable_errata
      lib_applicable = content_facet.applicable_errata

      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1).id)
      content_facet.bound_repositories = [@view_repo]
      content_facet.save!

      assert_equal_arrays lib_applicable, content_facet.applicable_errata
      refute_equal_arrays lib_applicable, content_facet.installable_errata
      assert_includes content_facet.installable_errata, Erratum.find(katello_errata(:security).id)
    end

    def test_update_applicability_counts
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1).id)
      content_facet.bound_repositories = [@view_repo]
      content_facet.update_applicability_counts

      assert_equal 1, content_facet.installable_security_errata_count
      assert_equal 0, content_facet.installable_enhancement_errata_count
      assert_equal 0, content_facet.installable_bugfix_errata_count
    end

    def test_with_installable_errata
      content_facet.bound_repositories = [Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1).id)]
      content_facet.save!

      content_facet_dev = katello_content_facets(:content_facet_two)
      content_facet_dev.bound_repositories = [Katello::Repository.find(katello_repositories(:fedora_17_x86_64_dev).id)]
      content_facet_dev.save!

      installable = content_facet_dev.applicable_errata & content_facet_dev.installable_errata
      non_installable = content_facet_dev.applicable_errata - content_facet_dev.installable_errata

      refute_empty non_installable
      refute_empty installable
      content_facets = Katello::Host::ContentFacet.with_installable_errata([installable.first])
      assert_includes content_facets, content_facet_dev

      content_facets = Katello::Host::ContentFacet.with_installable_errata([non_installable.first])
      refute_includes content_facets, content_facet_dev

      content_facets = Katello::Host::ContentFacet.with_installable_errata([installable.first, non_installable.first])
      assert_includes content_facets, content_facet_dev
    end

    def test_with_non_installable_errata
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1).id)
      content_facet.bound_repositories = [@view_repo]
      content_facet.save!

      unavailable = content_facet.applicable_errata - content_facet.installable_errata
      refute_empty unavailable
      content_facets = Katello::Host::ContentFacet.with_non_installable_errata([unavailable.first], [host.id])
      assert_includes content_facets, content_facet

      content_facets = Katello::Host::ContentFacet.with_non_installable_errata([content_facet.installable_errata.first], [host.id])
      refute_includes content_facets, content_facet
    end

    def test_available_errata_other_view
      @view_repo = Katello::Repository.find(katello_repositories(:rhel_6_x86_64_library_view_1).id)
      content_facet.bound_repositories = [@view_repo]
      content_facet.save!

      available_in_view = content_facet.installable_errata(@library, @library_view)
      assert_equal 1, available_in_view.length
      assert_includes available_in_view, Erratum.find(katello_errata(:security).id)
    end
  end

  class ContentFacetDebTest < ContentFacetBase
    let(:host_one) { hosts(:one) }
    let(:host_two) { hosts(:two) }
    let(:repo) { katello_repositories(:debian_10_amd64) }
    let(:deb_one) { katello_debs(:one) }
    let(:deb_two) { katello_debs(:two) }
    let(:deb_three) { katello_debs(:three) }

    def test_applicable_debs_searchable
      assert_includes ::Host.search_for("applicable_debs = \"#{deb_one.nav}\""), host_one
      refute_includes ::Host.search_for("applicable_debs = \"#{deb_one.nav}\""), host_two
      refute_includes ::Host.search_for("applicable_debs = \"#{deb_three.nav}\""), host_one
    end

    def test_upgradable_debs_searchable
      assert_includes deb_one.repositories, repo
      deb_two.repositories = []
      host_one.content_facet.bound_repositories << repo

      assert_includes ::Host.search_for("upgradable_debs = \"#{deb_one.nav}\""), host_one
      refute_includes ::Host.search_for("upgradable_debs = \"#{deb_two.nav}\""), host_one
    end

    def test_update_applicability_counts
      assert_includes deb_one.repositories, repo
      deb_two.repositories = []
      host_one.content_facet.bound_repositories << repo

      #shouldn't matter if facet is invalid
      host_one.content_facet.lifecycle_environment = katello_environments(:qa_path2)
      refute host_one.valid?

      host_one.content_facet.update_applicability_counts

      assert_equal 2, host_one.content_facet.applicable_deb_count
      assert_equal 1, host_one.content_facet.upgradable_deb_count
    end

    def test_installable_debs
      lib_applicable = host_one.applicable_debs
      cf_one = host_one.content_facet

      cf_one.bound_repositories = []
      cf_one.save!

      assert_equal_arrays lib_applicable, cf_one.applicable_debs
      refute_equal_arrays lib_applicable, cf_one.installable_debs
      refute_includes cf_one.installable_debs, deb_one
    end
  end

  class ContentFacetRpmTest < ContentFacetBase
    let(:host_one) { hosts(:one) }
    let(:host_two) { hosts(:two) }
    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:rpm_one) { katello_rpms(:one) }
    let(:rpm_two) { katello_rpms(:two) }
    let(:rpm_three) { katello_rpms(:three) }

    def test_applicable_rpms_searchable
      assert_includes ::Host.search_for("applicable_rpms = #{rpm_one.nvra}"), host_one
      refute_includes ::Host.search_for("applicable_rpms = #{rpm_one.nvra}"), host_two
      refute_includes ::Host.search_for("applicable_rpms = #{rpm_three.nvra}"), host_one
    end

    def test_upgradable_rpms_searchable
      assert_includes rpm_one.repositories, repo
      rpm_two.repositories = []
      host_one.content_facet.bound_repositories << repo

      assert_includes ::Host.search_for("upgradable_rpms = #{rpm_one.nvra}"), host_one
      refute_includes ::Host.search_for("upgradable_rpms = #{rpm_two.nvra}"), host_one
    end

    def test_update_applicability_counts
      assert_includes rpm_one.repositories, repo
      rpm_two.repositories = []
      host_one.content_facet.bound_repositories << repo

      #shouldn't matter if facet is invalid
      host_one.content_facet.lifecycle_environment = katello_environments(:qa_path2)
      refute host_one.valid?

      host_one.content_facet.update_applicability_counts

      assert_equal 2, host_one.content_facet.applicable_rpm_count
      assert_equal 1, host_one.content_facet.upgradable_rpm_count
    end

    def test_installable_rpms
      lib_applicable = host_one.applicable_rpms
      cf_one = host_one.content_facet

      cf_one.bound_repositories = []
      cf_one.save!

      assert_equal_arrays lib_applicable, cf_one.applicable_rpms
      refute_equal_arrays lib_applicable, cf_one.installable_rpms
      refute_includes cf_one.installable_rpms, rpm_one
    end
  end

  class ContentFacetModuleStreamTest < ContentFacetBase
    let(:host_one) { hosts(:one) }
    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:module_stream_one) { katello_module_streams(:one) }

    def test_applicable_not_upgradable_module_streams
      lib_applicable = host_one.applicable_module_streams
      cf_one = host_one.content_facet

      cf_one.bound_repositories = []
      cf_one.save!

      refute_equal_arrays lib_applicable, cf_one.installable_module_streams
      refute_includes cf_one.installable_module_streams, module_stream_one
      refute_includes HostAvailableModuleStream.upgradable([host_one]), module_stream_one
    end

    def test_upgradable_module_streams
      lib_applicable = host_one.applicable_module_streams
      cf_one = host_one.content_facet

      cf_one.bound_repositories << repo
      cf_one.save!

      upgradable = lib_applicable.select { |module_stream| module_stream.repositories.include?(repo) }

      assert_equal_arrays upgradable, cf_one.installable_module_streams

      upgradable_module_name_streams = HostAvailableModuleStream.upgradable([host_one]).map do |hams|
        [hams.available_module_stream.name, hams.available_module_stream.stream]
      end

      assert_includes upgradable_module_name_streams, [upgradable.first.name, upgradable.first.stream]

      host_one.content_facet.update_applicability_counts
      assert_equal 2, host_one.content_facet.applicable_module_stream_count
      assert_equal 1, host_one.content_facet.upgradable_module_stream_count
    end
  end

  class ImportErrataApplicabilityTest < ContentFacetBase
    def test_errata_counts
      content_facet.installable_security_errata_count = 1
      content_facet.installable_bugfix_errata_count = 2
      content_facet.installable_enhancement_errata_count = 3
      expected = {
        :security => 1,
        :bugfix => 2,
        :enhancement => 3,
        :total => 6,
        :applicable => { # it's fake data don't worry about it!
          :security => 0,
          :bugfix => 0,
          :enhancement => 0,
          :total => 0
        }
      }

      assert_equal expected, content_facet.errata_counts
    end
  end

  class BoundReposTest < ContentFacetBase
    let(:deb_repo) { katello_repositories(:debian_9_amd64) }
    let(:repo) { katello_repositories(:fedora_17_x86_64) }
    let(:view_repo) { katello_repositories(:fedora_17_x86_64_library_view_1) }

    def test_save_bound_repos_by_path_empty
      content_facet.bound_repositories << repo

      content_facet.update_repositories_by_paths([])

      assert_empty content_facet.bound_repositories
    end

    def test_save_bound_repos_by_paths
      content_facet.content_view = repo.content_view
      content_facet.lifecycle_environment = repo.environment
      assert_empty content_facet.bound_repositories

      content_facet.update_repositories_by_paths([
                                                   "/pulp/content/#{repo.relative_path}",
                                                   "/pulp/content/#{deb_repo.relative_path}",
                                                   "/pulp/content/Library/test/"
                                                 ])

      assert_equal_arrays content_facet.bound_repositories, [deb_repo, repo]
    end

    def test_save_bound_repos_by_paths_same_path
      content_facet.content_view = repo.content_view
      content_facet.lifecycle_environment = repo.environment
      content_facet.bound_repositories = [repo]
      ForemanTasks.expects(:async_task).never

      content_facet.update_repositories_by_paths(["/pulp/content/#{repo.relative_path}"])

      assert_equal content_facet.bound_repositories, [repo]
    end

    def test_no_useless_warnings
      content_facet.bound_repositories = [repo]
      Rails.logger.expects(:warn).never

      content_facet.update_repositories_by_paths(["/pulp/content/#{repo.relative_path}"])
    end

    def test_legit_warning
      content_facet.stubs(:update_bound_repositories)
      content_facet.bound_repositories = [repo]
      bogus_path = '/pulp/content/Default_Organization/Library/unknown'
      bogus_relative_path = bogus_path.gsub('/pulp/content/', '')
      expected_warning = "System #{host.name} (#{host.id}) requested binding to unknown repo #{bogus_relative_path}"
      Rails.logger.expects(:warn).with(expected_warning)

      content_facet.update_repositories_by_paths([bogus_path])
    end
  end

  class ContentHostExtensions < ContentFacetBase
    let(:host_one) { hosts(:one) }
    def setup
      assert host #force lazy load
      assert host_one
    end

    def test_content_view_search
      assert_includes ::Host::Managed.search_for("content_view = \"#{view.name}\""), host
    end

    def test_content_view_id_search
      assert_includes ::Host::Managed.search_for("content_view_id = #{view.id}"), host
    end

    def test_lifecycle_environment_search
      assert_includes ::Host::Managed.search_for("lifecycle_environment = #{library.name}"), host
    end

    def test_lifecycle_environment_id_search
      assert_includes ::Host::Managed.search_for("lifecycle_environment_id = #{library.id}"), host
    end

    def test_errata_status_search
      status = host.get_status(Katello::ErrataStatus)
      status.status = Katello::ErrataStatus::NEEDED_ERRATA
      status.reported_at = Time.now
      status.save!

      assert_includes ::Host::Managed.search_for("errata_status = errata_needed"), content_facet.host
    end

    def test_trace_status_search
      status = host.get_status(Katello::TraceStatus)
      status.status = Katello::TraceStatus::REQUIRE_PROCESS_RESTART
      status.reported_at = Time.now
      status.save!

      assert_includes ::Host::Managed.search_for("trace_status = process_restart_needed"), content_facet.host
    end

    def test_repository_search
      name = host_one.bound_repositories.sort.find { |repo| repo.name == "Fedora 17 x86_64" }&.name
      assert_includes ::Host::Managed.search_for("repository = \"#{name}\""), host_one
    end

    def test_content_label_search
      label = host_one.bound_repositories.sort.find { |repo| repo&.content&.label == "fedora" }&.content&.label
      assert_includes ::Host::Managed.search_for("repository_content_label = \"#{label}\""), host_one
    end
  end
end
