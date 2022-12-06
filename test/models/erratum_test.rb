require File.expand_path("repository_base", File.dirname(__FILE__))
require 'models/authorization/authorization_base'
module Katello
  class ErratumTestBase < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:rhel_6_x86_64)
      @security = katello_errata(:security)
      @bugfix = katello_errata(:bugfix)
      @enhancement = katello_errata(:enhancement)
      @host = hosts(:one)
      @host_without_errata = hosts(:two)
      @host_without_errata.content_facet.applicable_errata = []
    end
  end

  class ErratumTest < ErratumTestBase
    def test_repositories
      assert_includes @security.repository_ids, @repo.id
    end

    def test_create
      pulp_id = 'foo'
      assert Erratum.create!(:pulp_id => pulp_id)
      assert Erratum.find_by_pulp_id(pulp_id)
    end

    def test_search_reboot_suggested
      assert_includes Katello::Erratum.search_for("reboot_suggested = true"), @security
    end

    def test_search_modular
      assert_includes Katello::Erratum.search_for("modular = false"), @security
      assert_includes Katello::Erratum.search_for("modular = true"), katello_errata(:modular)
    end

    def test_freeform_search_looks_for_title
      assert_includes Katello::Erratum.search_for(@security.title[0..3]), @security
    end

    def test_with_identifiers_single
      assert_includes Katello::Erratum.with_identifiers(@security.id), @security
    end

    def test_with_identifiers_multiple
      errata = Katello::Erratum.with_identifiers([@security.id, @bugfix.pulp_id, @enhancement.errata_id])

      assert_equal 3, errata.length
      assert_includes errata, @security
      assert_includes errata, @bugfix
      assert_includes errata, @enhancement
    end

    def test_of_type
      assert_includes Erratum.of_type(Erratum::SECURITY), @security
      refute_includes Erratum.of_type(Erratum::SECURITY), @bugfix
      refute_includes Erratum.of_type(Erratum::SECURITY), @enhancement
    end

    def test_applicable_to_hosts
      errata = Erratum.applicable_to_hosts(::Host.where(id: [@host, @host_without_errata].map(&:id)))
      assert_includes errata, @security
      assert_includes errata, @bugfix
      refute_includes errata, @enhancement
    end

    def test_applicable_to_hosts_dashboard
      errata = Erratum.applicable_to_hosts_dashboard(::Host.where(:id => [@host.id, @host_without_errata.id]))
      assert_includes errata, @security
      assert_includes errata, @bugfix
      refute_includes errata, @enhancement
    end

    def test_applicable_to_hosts_dashboard_respects_filter
      assert_empty Erratum.applicable_to_hosts_dashboard(::Host.search_for("compute_resource = SOMENAME"))
      host = FactoryBot.build(:host, :with_content, :with_subscription,
                                      :content_view => katello_content_views(:library_dev_view),
                                      :lifecycle_environment => katello_environments(:library),
                                      :compute_resource_id => compute_resources(:one).id)
      host.stubs(:update_candlepin_associations)
      host.save
      host.content_facet.applicable_errata << @security
      host.save
      refute_empty Erratum.applicable_to_hosts_dashboard(::Host.search_for("compute_resource = #{compute_resources(:one).name}"))
    end

    def test_not_applicable_to_hosts
      assert_empty Erratum.applicable_to_hosts(::Host.where(id: [@host_without_errata].map(&:id)))
    end

    def test_large_sync_repository_association
      Katello::Erratum.stubs(:backend_identifier_field).returns("erratum_pulp3_href")
      i, ids, ids_href_map = 0, [], {}
      while (i < 70_000)
        ids[i] = ["errata_id_#{i}"]
        ids_href_map["errata_id_#{i}"] = "pulp_href#{i}"
        i += 1
      end
      Katello::Erratum.import([:pulp_id], ids, validate: false)

      content_type = Katello::RepositoryTypeManager.find_content_type('erratum')
      service_class = content_type.pulp3_service_class

      indexer = Katello::ContentUnitIndexer.new(content_type: content_type, repository: @repo)
      tracker = Katello::ContentUnitIndexer::RepoAssociationTracker.new(content_type, service_class, @repo)
      ids.each do |errata_id|
        tracker.push({pulp_href: ids_href_map[errata_id.first], id: errata_id.first}.with_indifferent_access)
      end
      indexer.sync_repository_associations(tracker)

      post_repo_erratum_size = @repo.errata.size
      assert_equal post_repo_erratum_size, 70_000
    end
  end

  class ErratumAvailableTest < ErratumTestBase
    def setup
      super
      @host = hosts(:one)
      @host.content_facet.assign_single_environment(
        content_view: katello_content_views(:library_dev_view),
        lifecycle_environment: katello_environments(:library)
      )
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)
      @host.content_facet.bound_repositories = [@repo, @view_repo]
      @host.content_facet.save!
    end

    def test_hosts_available
      assert_includes @security.hosts_available, @host.content_facet
      assert_includes @security.hosts_available(@host.organization), @host.content_facet
      available_errata = @security.hosts_available
      assert_equal available_errata.uniq.size, available_errata.size
      refute_includes @security.hosts_available, @host_without_errata
      refute_includes @bugfix.hosts_available(@host.organization), @host_without_errata
    end

    def test_installable_for_hosts
      errata = Erratum.installable_for_hosts([@host, @host_without_errata])

      assert_includes errata, @security
      assert_includes errata, @bugfix
      refute_includes errata, @enhancement
    end

    def test_installable_for_hosts_with_no_bound_repos
      # make sure the @host has no bound repositories
      @host.content_facet.bound_repositories = []
      @host.content_facet.save!
      errata = Erratum.installable_for_hosts([@host, @host_without_errata])
      assert_empty errata
    end

    def test_installable_for_hosts_with_repos
      #Tests issue #10681
      errata = Erratum.installable_for_hosts([@host, @host_without_errata]).in_repositories(@repo)
      assert_includes errata, @security
      assert_includes errata, @bugfix
      refute_includes errata, @enhancement
    end

    def test_installable_for_hosts_without_errata
      #Tests issue #15024
      errata = Erratum.installable_for_hosts([@host_without_errata])
      refute_includes errata, @security
      refute_includes errata, @bugfix
      refute_includes errata, @enhancement
    end
  end

  class ErratumInstallableForHostsTest < AuthorizationTestBase
    def setup
      super
      @repo = katello_repositories(:rhel_6_x86_64)
      @security = katello_errata(:security)
      @host = hosts(:one)
      @host.content_facet.assign_single_environment(
        content_view: katello_content_views(:library_dev_view),
        lifecycle_environment: katello_environments(:library)
      )
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)
      @host.content_facet.bound_repositories = [@repo, @view_repo]
      @host.content_facet.save!
    end

    def test_returns_installable_errata_for_host_with_hostgroup
      hostgroup = ::Hostgroup.create!(name: "foo",
                                      organizations: [@host.organization],
                                      locations: [@host.location])
      @host.hostgroup = hostgroup
      @host.stubs(:update_candlepin_associations)
      @host.save(validate: false)
      User.current = User.find(users('restricted').id)
      setup_current_user_with_permissions([{ name: "view_hosts",
                                             search: "hostgroup=#{hostgroup.name}"},
                                           { name: "edit_hosts",
                                             search: "hostgroup=#{hostgroup.name}"},
                                           { name: "view_organizations",
                                             resource_type: "Organization"},
                                           { name: "view_hostgroups", search: "name=#{hostgroup.name}"},
                                           { name: "edit_hostgroups", search: "name=#{hostgroup.name}"},
                                           { name: 'view_host_collections'},
                                           { name: 'edit_host_collections'}
                                          ],
                                          organizations: [@host.organization],
                                          locations: [@host.location])
      errata = Erratum.installable_for_hosts(::Host::Managed.unscoped.authorized(:view_hosts))
      assert_includes errata, @security
    end
  end
end
