require 'katello_test_helper'

module Katello
  class ContentViewErratumFilterTest < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:fedora_17_x86_64)
    end

    def test_erratum_by_id_returns_arel_for_specified_errata_id
      erratum = katello_errata(:security)
      @repo.errata = [erratum]
      @repo.save!

      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :errata_id => erratum.errata_id)
      filter = id_rule.filter
      filter.reload

      assert_equal "\"katello_errata\".\"errata_id\" IN ('#{erratum.errata_id}')", filter.generate_clauses(@repo).to_sql
    end

    def test_errata_by_start_date_returns_arel_for_errata_by_updated_date_and_errata_type
      start_date = "2017-11-12"
      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :start_date => start_date)
      filter = id_rule.filter
      filter.reload

      assert_equal "\"katello_errata\".\"updated\" >= '#{start_date}' AND \"katello_errata\".\"errata_type\" IN ('bugfix', 'enhancement', 'security')",
        filter.generate_clauses(@repo).to_sql
    end

    def test_errata_by_start_date_returns_arel_for_errata_by_issued_date_and_errata_type
      start_date = "2017-11-12"
      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :start_date => start_date,
                                  :date_type => ContentViewErratumFilterRule::ISSUED)
      filter = id_rule.filter
      filter.reload

      assert_equal "\"katello_errata\".\"issued\" >= '#{start_date}' AND \"katello_errata\".\"errata_type\" IN ('bugfix', 'enhancement', 'security')",
        filter.generate_clauses(@repo).to_sql
    end

    def test_errata_by_end_date_returns_arel_for_errata_by_updated_date_and_errata_type
      end_date = "2020-01-01"
      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :end_date => end_date)
      filter = id_rule.filter
      filter.reload

      assert_equal "\"katello_errata\".\"updated\" <= '#{end_date}' AND \"katello_errata\".\"errata_type\" IN ('bugfix', 'enhancement', 'security')",
        filter.generate_clauses(@repo).to_sql
    end

    def test_errata_by_end_date_returns_arel_for_errata_by_issued_date_and_errata_type
      end_date = "2020-01-01"
      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :end_date => end_date,
                                  :date_type => ContentViewErratumFilterRule::ISSUED)
      filter = id_rule.filter
      filter.reload

      assert_equal "\"katello_errata\".\"issued\" <= '#{end_date}' AND \"katello_errata\".\"errata_type\" IN ('bugfix', 'enhancement', 'security')",
        filter.generate_clauses(@repo).to_sql
    end

    def test_errata_by_type_returns_arel_by_errata_type
      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :types => ['bugfix'])
      filter = id_rule.filter
      filter.reload

      assert_equal "\"katello_errata\".\"errata_type\" IN ('bugfix')",
        filter.generate_clauses(@repo).to_sql
    end

    def test_content_unit_pulp_ids_by_errata_id_returns_errata_package_pulp_hrefs
      rpm1 = @repo.rpms.first
      rpm2 = @repo.rpms.last
      erratum1 = Katello::Erratum.new(:pulp_id => "one", :errata_id => "ERRATA1")
      erratum1.packages << Katello::ErratumPackage.new(:filename => rpm1.filename, :name => "e1", :nvrea => "e1")
      erratum2 = Katello::Erratum.new(:pulp_id => "two", :errata_id => "ERRATA2")
      erratum2.packages << Katello::ErratumPackage.new(:filename => rpm2.filename, :name => "e2", :nvrea => "e2")

      @repo.errata = [erratum1, erratum2]
      @repo.save!

      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :errata_id => erratum1.errata_id)
      filter = id_rule.filter
      filter.reload

      assert_equal [rpm1.pulp_id], filter.content_unit_pulp_ids(@repo)
    end

    def test_content_unit_pulp_ids_by_updated_start_date_returns_pulp_hrefs
      rpm1 = @repo.rpms.first
      rpm2 = @repo.rpms.last
      erratum1 = Katello::Erratum.new(:pulp_id => "one", :errata_id => "ERRATA1", :updated => "2018-01-01")
      erratum1.packages << Katello::ErratumPackage.new(:filename => rpm1.filename, :name => "e1", :nvrea => "e1")
      erratum2 = Katello::Erratum.new(:pulp_id => "two", :errata_id => "ERRATA2", :updated => "2019-06-01")
      erratum2.packages << Katello::ErratumPackage.new(:filename => rpm2.filename, :name => "e2", :nvrea => "e2")

      @repo.errata = [erratum1, erratum2]
      @repo.save!

      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :start_date => "2019-01-01")
      filter = id_rule.filter
      filter.reload

      assert_equal [rpm2.pulp_id], filter.content_unit_pulp_ids(@repo)
    end

    def test_content_unit_pulp_ids_by_issued_start_date_returns_pulp_hrefs
      rpm1 = @repo.rpms.first
      rpm2 = @repo.rpms.last
      erratum1 = Katello::Erratum.new(:pulp_id => "one", :errata_id => "ERRATA1", :issued => "2018-01-01")
      erratum1.packages << Katello::ErratumPackage.new(:filename => rpm1.filename, :name => "e1", :nvrea => "e1")
      erratum2 = Katello::Erratum.new(:pulp_id => "two", :errata_id => "ERRATA2", :issued => "2019-06-01")
      erratum2.packages << Katello::ErratumPackage.new(:filename => rpm2.filename, :name => "e2", :nvrea => "e2")

      @repo.errata = [erratum1, erratum2]
      @repo.save!

      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :start_date => "2019-01-01",
                                  :date_type => ContentViewErratumFilterRule::ISSUED)
      filter = id_rule.filter
      filter.reload

      assert_equal [rpm2.pulp_id], filter.content_unit_pulp_ids(@repo)
    end

    def test_content_unit_pulp_ids_by_updated_end_date_returns_pulp_hrefs
      rpm1 = @repo.rpms.first
      rpm2 = @repo.rpms.last
      erratum1 = Katello::Erratum.new(:pulp_id => "one", :errata_id => "ERRATA1", :updated => "2018-01-01")
      erratum1.packages << Katello::ErratumPackage.new(:filename => rpm1.filename, :name => "e1", :nvrea => "e1")
      erratum2 = Katello::Erratum.new(:pulp_id => "two", :errata_id => "ERRATA2", :updated => "2019-06-01")
      erratum2.packages << Katello::ErratumPackage.new(:filename => rpm2.filename, :name => "e2", :nvrea => "e2")

      @repo.errata = [erratum1, erratum2]
      @repo.save!

      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :end_date => "2019-01-01")
      filter = id_rule.filter
      filter.reload
      assert_equal [rpm1.pulp_id], filter.content_unit_pulp_ids(@repo)
    end

    def test_content_unit_pulp_ids_by_issued_end_date_returns_pulp_hrefs
      rpm1 = @repo.rpms.first
      rpm2 = @repo.rpms.last
      erratum1 = Katello::Erratum.new(:pulp_id => "one", :errata_id => "ERRATA1", :issued => "2018-01-01")
      erratum1.packages << Katello::ErratumPackage.new(:filename => rpm1.filename, :name => "e1", :nvrea => "e1")
      erratum2 = Katello::Erratum.new(:pulp_id => "two", :errata_id => "ERRATA2", :issued => "2019-06-01")
      erratum2.packages << Katello::ErratumPackage.new(:filename => rpm2.filename, :name => "e2", :nvrea => "e2")

      @repo.errata = [erratum1, erratum2]
      @repo.save!

      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :start_date => "2019-01-01",
                                  :date_type => ContentViewErratumFilterRule::ISSUED)
      filter = id_rule.filter
      filter.reload

      assert_equal [rpm2.pulp_id], filter.content_unit_pulp_ids(@repo)
    end

    def test_content_unit_pulp_ids_by_errata_type
      rpm1 = @repo.rpms.first
      rpm2 = @repo.rpms.last

      erratum1 = Katello::Erratum.new(:pulp_id => "one", :errata_id => "ERRATA1", :errata_type => 'bugfix')
      erratum1.packages << Katello::ErratumPackage.new(:filename => rpm1.filename, :name => "e1", :nvrea => "e1")
      erratum2 = Katello::Erratum.new(:pulp_id => "two", :errata_id => "ERRATA2", :errata_type => 'security')
      erratum2.packages << Katello::ErratumPackage.new(:filename => rpm2.filename, :name => "e2", :nvrea => "e2")

      @repo.errata = [erratum2]
      @repo.save!

      id_rule = FactoryBot.create(:katello_content_view_erratum_filter_rule, :types => ['security'])
      filter = id_rule.filter
      filter.reload

      assert_equal [rpm2.pulp_id], filter.content_unit_pulp_ids(@repo)
    end
  end
end
