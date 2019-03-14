require File.expand_path("repository_base", File.dirname(__FILE__))

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

    def test_create_truncates_long_title
      attrs = {:pulp_id => 'foo', :title => "This life, which had been the tomb of " \
        "his virtue and of his honour is but a walking shadow; a poor player, " \
        "that struts and frets his hour upon the stage, and then is heard no more: " \
        "it is a tale told by an idiot, full of sound and fury, signifying nothing." \
        " - William Shakespeare"}
      assert Erratum.create!(attrs)
      assert_equal Erratum.find_by_pulp_id(attrs[:pulp_id]).title.size, 255
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
      assert Erratum.of_type(Erratum::SECURITY).include?(@security)
      refute Erratum.of_type(Erratum::SECURITY).include?(@bugfix)
      refute Erratum.of_type(Erratum::SECURITY).include?(@enhancement)
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
      assert Erratum.applicable_to_hosts_dashboard(::Host.search_for("compute_resource = SOMENAME")).empty?
      host = FactoryBot.build(:host, :with_content, :with_subscription,
                                      :content_view => katello_content_views(:library_dev_view),
                                      :lifecycle_environment => katello_environments(:library),
                                      :compute_resource_id => compute_resources(:one).id)
      host.save
      host.content_facet.applicable_errata << @security
      host.save
      refute Erratum.applicable_to_hosts_dashboard(::Host.search_for("compute_resource = #{compute_resources(:one).name}")).empty?
    end

    def test_not_applicable_to_hosts
      assert_empty Erratum.applicable_to_hosts(::Host.where(id: [@host_without_errata].map(&:id)))
    end
  end

  class ErratumAvailableTest < ErratumTestBase
    def setup
      super
      @host = hosts(:one)
      @host.content_facet.content_view = katello_content_views(:library_dev_view)
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
end
