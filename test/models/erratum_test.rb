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

    def test_clean_filter_rules
      filter = FactoryBot.build(:katello_content_view_erratum_filter, :inclusion => true)
      security_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule,
                                   :filter => filter,
                                   :errata_id => @security.errata_id)
      bugfix_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule,
                                   :filter => filter,
                                   :errata_id => @bugfix.errata_id)
      enhancement_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule,
                                   :filter => filter,
                                   :errata_id => @enhancement.errata_id)
      @repo.errata << @enhancement
      content_type = Katello::RepositoryTypeManager.find_content_type('erratum')
      indexer = Katello::ContentUnitIndexer.new(content_type: content_type, repository: @repo)
      repo_associations = ::Katello::RepositoryErratum.where(erratum_id: [@bugfix.id, @enhancement.id], repository_id: @repo.id)
      filter.content_view.update(organization_id: @repo.organization.id)
      filter.content_view.repositories << @repo

      indexer.clean_filter_rules(repo_associations)
      security_rule.reload
      assert_raises ActiveRecord::RecordNotFound do
        bugfix_rule.reload
      end
      assert_raises ActiveRecord::RecordNotFound do
        enhancement_rule.reload
      end
    end

    def test_copy_repository_associations_with_prn
      repo_one = @repo
      repo_two = katello_repositories(:rhel_6_x86_64_dev)

      repo_one.errata = [@security]

      repo_erratum = Katello::RepositoryErratum.find_by(repository_id: repo_one.id, erratum_id: @security.id)
      repo_erratum.update!(erratum_prn: "prn:rpm.updaterecord:test-uuid-12345")

      repo_two.errata = [@bugfix]

      Katello::Erratum.copy_repository_associations(repo_one, repo_two)

      assert_equal [@security], repo_two.reload.errata

      copied_repo_erratum = Katello::RepositoryErratum.find_by(repository_id: repo_two.id, erratum_id: @security.id)
      assert_equal "prn:rpm.updaterecord:test-uuid-12345", copied_repo_erratum.erratum_prn
    end
  end

  class ErratumAvailableTest < ErratumTestBase
    def setup
      super
      @host = hosts(:one)
      cvenv = Katello::ContentViewEnvironment.find_by_cv_and_lce!(
        katello_content_views(:library_dev_view).id,
        katello_environments(:library).id
      )
      @host.content_facet.content_view_environments = [cvenv]
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

    def test_hosts_available_count
      assert_equal @security.hosts_available.count, @security.hosts_available_count
      assert_equal @security.hosts_available(@host.organization).count, @security.hosts_available_count(@host.organization)
    end

    def test_module_streams
      streams = katello_errata(:modular).module_streams

      assert_equal 1, streams.size
      assert_equal 'three', streams.first[:name]
      assert_equal 'noitsariver', streams.first[:stream]
      assert_equal ['foobarmod-1.2.3'], streams.first[:packages]
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
      cvenv = Katello::ContentViewEnvironment.find_by_cv_and_lce!(
        katello_content_views(:library_dev_view).id,
        katello_environments(:library).id
      )
      @host.content_facet.content_view_environments = [cvenv]
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)
      @host.content_facet.bound_repositories = [@repo, @view_repo]
      @host.content_facet.save!
    end

    def test_advisory_ids_with_explicit_errata_id
      assert_equal [@security.errata_id], @host.advisory_ids(search: "errata_id = #{@security.errata_id}")
    end

    def test_advisory_ids_resolves_bare_security_identifier
      identifier = katello_erratum_cves(:cve).cve_id

      assert_equal [@security.errata_id], @host.advisory_ids(search: identifier)
      assert_equal [@security.errata_id], @host.advisory_ids(search: identifier.downcase)
    end

    def test_advisory_ids_resolves_bare_bugzilla_id
      bug_id = "1234567"
      Katello::ErratumBugzilla.create!(:erratum => @security, :bug_id => bug_id,
                                       :href => "https://bugzilla.redhat.com/#{bug_id}")

      assert_equal [@security.errata_id], @host.advisory_ids(search: bug_id)
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
                                           { name: 'edit_host_collections'},
                                          ],
                                          organizations: [@host.organization],
                                          locations: [@host.location])
      errata = Erratum.installable_for_hosts(::Host::Managed.unscoped.authorized(:view_hosts))
      assert_includes errata, @security
    end
  end

  class ErratumSearchTest < ActiveSupport::TestCase
    def setup
      @security = katello_errata(:security)
    end

    def test_free_text_search_does_not_scan_security_reference_tables
      sql = Erratum.search_for("kernel").to_sql

      refute_match(/katello_erratum_cves/, sql)
      refute_match(/katello_erratum_bugzillas/, sql)
      assert_match(/katello_erratum_cves/, Erratum.search_for(katello_erratum_cves(:cve).cve_id).to_sql)
    end

    def test_search_for_matches_a_bare_security_identifier
      identifier = katello_erratum_cves(:cve).cve_id

      assert_includes Erratum.search_for(identifier), @security
      assert_includes Erratum.search_for(identifier.downcase), @security
      assert_includes Erratum.search_for("cve = #{identifier}"), @security
    end

    def test_search_for_matches_a_bare_bugzilla_id
      Katello::ErratumBugzilla.create!(:erratum => @security, :bug_id => "1234567",
                                       :href => "https://bugzilla.redhat.com/1234567")

      assert_includes Erratum.search_for("1234567"), @security
      assert_includes Erratum.search_for("bug = 1234567"), @security
    end

    def test_search_for_negates_identifiers
      identifier = katello_erratum_cves(:cve).cve_id

      refute_includes Erratum.search_for("-#{identifier}"), @security
      assert_includes Erratum.search_for("-#{identifier}"), katello_errata(:bugfix)
    end

    def test_search_for_matches_identifiers_inside_a_compound_query
      identifier = katello_erratum_cves(:cve).cve_id

      assert_includes Erratum.search_for("#{identifier} and severity = #{@security.severity}"), @security
      assert_includes Erratum.search_for("\"#{identifier}\""), @security
      assert_includes Erratum.search_for(identifier[0, 8]), @security
    end

    def test_search_for_uses_ilike_so_the_trigram_indexes_apply
      identifier = katello_erratum_cves(:cve).cve_id

      ["kernel", identifier, identifier.downcase].each do |query|
        sql = Erratum.search_for(query).to_sql
        assert_match(/ILIKE/i, sql)
        refute_match(/LOWER\s*\(/i, sql)
      end
    end

    def test_explicit_relation_fields_are_not_rewritten
      sql = Erratum.search_for("package_name = 1234567").to_sql

      assert_match(/katello_erratum_packages/, sql)
      refute_match(/katello_erratum_bugzillas/, sql)
      refute_match(/katello_erratum_cves/, sql)
    end
  end
end
