#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'digest'

require 'minitest_helper'
require './test/support/repository_support'

class ContentViewScenarioTest < MiniTest::Rails::ActiveSupport::TestCase
  extend ActiveRecord::TestFixtures

  fixtures :all

  REPO1_LABEL =  'publish_test_repo'
  REPO2_LABEL = 'publish_test_repo_2'

  @@org = nil

  def self.before_suite
    loaded_fixtures = load_fixtures

    models = ["Organization", "KTEnvironment", "User", "ContentViewEnvironment","ContentViewDefinitionBase",
              "ContentViewDefinition", "Repository", "ContentView", "EnvironmentProduct", "ContentViewVersion",
              "ComponentContentView", "System", "Product", "ContentViewVersion", "ContentViewDefinitionArchive",
              "Filter", "PackageRule", "ErratumRule", "Changeset", "PromotionChangeset"]
    disable_glue_layers([], models, true)

    ContentView.redefine_method(:cp_environment_id) do |env|
      #Needed a way to make a consistent environment id in candlepin
      # for VCR cassettes.  Candlepin won't generate one for us
      Digest("MD5").new.update("#{self.organization.label}-#{env.label}-#{self.label}").to_s
    end

    #for subscription creation, we have to stub the Date
    Date.stubs(:today).returns(Date.new(2013, 7, 15))

    VCR.insert_cassette('scenarios/publish_base', :match_requests_on => [:path, :params, :method, :body_json])

    @@admin = User.find(loaded_fixtures['users']['admin']['id'])
    User.current = @@admin

    #setup the org and sync the repo
    @@org = Organization.create!(:name=>'test_scenario_org', :label=>'test_scenario_org')
    @@dev = KTEnvironment.create!(:name=>"Dev", :organization=>@@org, :prior=>@@org.library, :label=>"dev")
    provider = Provider.create!(:organization=>@@org, :name=>'publish_test_provider', :provider_type=>Provider::CUSTOM)

    @@product = Product.new(:provider=>provider, :name=>'publish_test_product', :label=>'publish_test_product')
    @@product.environments << @@org.library
    @@product.save!

    @@repo1 = @@product.add_repo(REPO1_LABEL, REPO1_LABEL, RepositorySupport.repo_url, 'yum')
    @@repo2 = @@product.add_repo(REPO2_LABEL, REPO2_LABEL, RepositorySupport.repo_url, 'yum')
    task = @@repo1.sync
    TaskSupport.wait_on_tasks(task)
    @@repo1 = Repository.find(@@repo1) #reload repo so we can index the content
    @@repo1.index_content
  end

  def self.after_suite
    org = @@org.reload
    org_destroy = OrganizationDestroyer.new(org)
    org_destroy.setup(org)
    #org destroy takes ~60 seconds even in none mode :/
    org_destroy.run if VCR.live?
    VCR.eject_cassette
  end

  def setup
    @definition = ContentViewDefinition.create!(:name=>'publish_test_def', :organization=>@@org)
  end

  def teardown
    @definition.destroy
  end

  def test_product_publish_no_filters
    #create a definition with a product and no filters
    # publish the definition
    vcr_perform('product_publish_no_filters') do
      begin
        @definition.products << @@product
        @definition.save!

        view = @definition.publish('test_view', '', 'test_view', {:async=>false})
        #validate Content view environments
        assert_equal 1, view.content_view_environments.count
        assert_equal 2, view.content_view_environments.first.content_ids.count

        #validate version info
        assert_equal 1, view.versions.count
        assert_equal 2, view.versions.first.repositories.count

        #validate packages all got copied
        view_repo = view.versions.first.repositories.where(:label=>REPO1_LABEL).first
        assert_equal @@repo1.package_ids, view_repo.package_ids

        #validate non-empty errata all got copied
        assert_equal 2, view_repo.errata.count

      ensure
        view.destroy if view
      end
    end
  end

  def test_content_view_refresh
    # Create a definition with just a single repo
    #   with no filters
    # Publish the definition
    # Add the full product to the definition
    # add a package filter
    # refresh the view
    vcr_perform('content_view_refresh') do
      begin
        @definition.repositories << @@repo1
        @definition.save!

        #publish version 1
        view = @definition.publish('test_view', '', 'test_view', {:async=>false})
        #should only have 1 cv_env with a single content
        assert_equal 1, view.content_view_environments.count
        assert_equal 1, view.content_view_environments.first.content_ids.count
        cv_env = view.content_view_environments.first

        # validate all packages are present
        view_repo = view.versions.first.repositories.where(:label=>REPO1_LABEL).first
        assert_equal @@repo1.package_ids, view_repo.package_ids

        #add the full product and filter
        @definition.repositories.clear
        @definition.products << @@product
        should_not_include = "elephant"
        add_filter(@definition, [], [@@repo1], FilterRule::PACKAGE, false, {"units"=>[{:name=>should_not_include}]})
        @definition.save!

        view.refresh_view(:async=>false)
        view = view.reload

        #should still have only 1 cv_env which is the same, but now with 2 contents
        assert_equal 1, view.content_view_environments.count
        assert_equal cv_env, view.content_view_environments.first
        assert_equal 2, view.content_view_environments.first.content_ids.count

        #validate that the repo is the same (wasn't deleted)
        new_view_repo = view.versions.first.repositories.where(:label=>REPO1_LABEL).first
        assert_equal view_repo, new_view_repo

        #refreshed repo should not have the filtered package
        packages = new_view_repo.packages
        refute_empty packages
        assert_empty packages.select{|p| p.name == should_not_include}
      ensure
        view.destroy
      end
    end
  end

  def test_promote_content_view
    # Create a definition with just a single repo
    #   with no filters
    # Publish the definition
    # Promote the CV to Dev
    # Add a package name filter to the definition
    # Refresh the Content View
    # Re-promote the CV to Dev
    vcr_perform('content_view_promote') do
      begin
        @definition.repositories << @@repo1
        @definition.save!

        #publish version 1
        view = @definition.publish('test_view', '', 'test_view', {:async=>false})

        #promote version 1 To Dev
        changeset = PromotionChangeset.new(:environment=>@@dev, :name=>"PromoteContentView")
        changeset.content_views << view
        changeset.state = Changeset::REVIEW
        changeset.save!
        changeset.apply(:async=>false)

        view = view.reload

        #should be 2 cv_envs and only one version
        assert_equal 2, view.content_view_environments.count
        assert_equal 1, view.versions.count

        #save the cv_envs and repos to validate they are persisted
        original_cv_envs = view.content_view_environments.all.sort
        original_repos = view.versions.first.repositories.all.sort

        #refresh the view with a filter
        should_not_include = "elephant"
        add_filter(@definition, [], [@@repo1], FilterRule::PACKAGE, false, {"units"=>[{:name=>should_not_include}]})
        @definition.save!
        view.refresh_view(:async=>false)
        view = view.reload

        #Refreshed view should now have 2 versions
        #  and cv_envs and repos should be the same
        assert_equal original_cv_envs, view.content_view_environments.sort
        assert_equal 2, view.versions.count
        assert_equal original_repos, (view.versions[0].repositories + view.versions[1].repositories).sort

        # re-promote view
        changeset = PromotionChangeset.new(:environment=>@@dev, :name=>"PromoteContentView_2")
        changeset.content_views << view
        changeset.state = Changeset::REVIEW
        changeset.save!
        changeset.apply(:async=>false)

        view = view.reload

        # cv_envs should be persisted
        # Should only be one version
        # which should have 2 environments
        assert_equal original_cv_envs, view.content_view_environments.sort
        assert_equal 1, view.versions.count
        version = view.versions.first
        assert_equal 2, version.environments.count
        assert_equal original_repos, version.repositories.sort

        version.repositories.each do |repo|
          refute_empty repo.packages
          assert_empty repo.packages.select{|p| p.name == should_not_include}
        end
      ensure
        view.versions.each{|v| v.repositories.destroy_all}
        view.destroy
        @@dev.changeset_history.destroy_all
      end
    end

  end

  def test_repo_publish_no_filters
    # Create a definition with just a single repo
    #   with no filters
    # Publish the definition
    vcr_perform('repo_publish_no_filters') do
      begin
        @definition.repositories << @@repo1
        @definition.save!
        view = @definition.publish('test_view', '', 'test_view', {:async=>false})

        assert_equal 1, view.content_view_environments.count
        assert_equal 1, view.content_view_environments.first.content_ids.count

        assert_equal 1, view.versions.first.repositories.count
        view_repo = view.versions.first.repositories.where(:label=>REPO1_LABEL).first
        assert_equal @@repo1.package_ids, view_repo.package_ids
      ensure
        view.destroy if view
      end
    end
  end

  def test_all_version_blacklist
    # Create a definition with just a single repo
    # Add a filter with an all version filter
    # Publish the definition
    vcr_perform('all_version_blacklist') do
      begin
        should_include = "cheetah"
        should_not_include = "elephant"

        @definition.repositories << @@repo1
        @definition.save!

        add_filter(@definition, [], [@@repo1], FilterRule::PACKAGE, false, {"units"=>[{:name=>should_not_include}]})

        view = @definition.publish('test_view', '', 'test_view', {:async=>false})
        view_repo = view.versions.first.repositories.first

        packages = view_repo.packages
        assert packages.select{|p| p.name == should_include}.count > 0
        assert_equal 0, packages.select{|p| p.name == should_not_include}.count

      ensure
        view.destroy if view
      end
    end
  end

  def test_package_newer_than_blacklist
    # Create a definition with just a single repo
    # Add a package filter with a newer than version blacklist
    # Publish the definition
    vcr_perform('package_newer_than_blacklist') do
      begin
        should_include = "cheetah"
        should_include_newer_than = '0.4'

        should_not_include = "elephant"
        should_not_include_newer_than = '0.2'

        @definition.repositories << @@repo1
        @definition.save!

        add_filter(@definition, [], [@@repo1], FilterRule::PACKAGE, false,
                   {"units"=>[{"name"=>should_not_include, "min_version"=>should_not_include_newer_than},
                              {"name"=>should_include, "min_version"=>should_include_newer_than}]})
        view = @definition.publish('test_view', '', 'test_view', {:async=>false})
        view_repo = view.versions.first.repositories.first

        packages = view_repo.packages
        assert_equal 1, packages.select{|p| p.name == should_include}.count
        assert_equal 0, packages.select{|p| p.name == should_not_include}.count
      ensure
        view.destroy if view
      end
    end
  end

  def test_package_older_than_blacklist
    # Create a definition with just a single repo
    # Add a package filter with an older than version blacklist
    # Publish the definition
    vcr_perform('package_older_than_blacklist') do
      begin
        should_include = "cheetah"
        should_not_include = "elephant"
        older_than = '0.4'



        @definition.repositories << @@repo1
        @definition.save!

        add_filter(@definition, [], [@@repo1], FilterRule::PACKAGE, false,
                   {"units"=>[{"name"=>should_not_include, "max_version"=>older_than}]})
        view = @definition.publish('test_view', '', 'test_view', {:async=>false})
        view_repo = view.versions.first.repositories.first

        packages = view_repo.packages

        assert_equal 1, packages.select{|p| p.name == should_include}.count
        assert_equal 0, packages.select{|p| p.name == should_not_include}.count
      ensure
        view.destroy if view
      end
    end
  end

  def test_errata_type_filter
    # Create a definition with just a single repo
    # Add an errata filter specifying an errata type
    # Publish the definition
    vcr_perform('errata_type_blacklist') do
      begin
        blacklist_type = 'bugfix'

        should_include = "RHEA-2010:0002"
        should_not_include = "RHEA-2010:0003"
        should_not_include_pkg = "monkey"

        @definition.repositories << @@repo1
        @definition.save!

        add_filter(@definition, [], [@@repo1], FilterRule::ERRATA, false,
                   {"errata_type"=>[blacklist_type]})
        view = @definition.publish('test_view', '', 'test_view', {:async=>false})

        view_repo = view.versions.first.repositories.first
        packages = view_repo.packages
        errata = view_repo.errata

        assert_equal 1, errata.select{|p| p.errata_id == should_include}.count
        assert_equal 0, errata.select{|p| p.errata_id == should_not_include}.count
        assert_equal 0, packages.select{|p| p.name == should_not_include_pkg}.count
      ensure
        view.destroy if view
      end
    end
  end

  def test_errata_date_filter_blacklist
    # Create a definition with just a single repo
    # Add an errata filter specifying a date range
    # Publish the definition
    vcr_perform('errata_date_filter_blacklist') do
      begin
        blacklist_type = 'bugfix'

        should_include = "RHEA-2010:0002" #has date of 2010-01-01
        should_not_include = "RHEA-2010:0003" #has date of 2010-02-01
        should_not_include_pkg = "monkey"

        start_date =  Time.parse("2010-01-31").to_i


        @definition.repositories << @@repo1
        @definition.save!

        add_filter(@definition, [], [@@repo1], FilterRule::ERRATA, false,
                   {"date_range"=>{"start"=>start_date}})
        view = @definition.publish('test_view', '', 'test_view', {:async=>false})

        view_repo = view.versions.first.repositories.first
        packages = view_repo.packages
        errata = view_repo.errata

        assert_equal 1, errata.select{|p| p.errata_id == should_include}.count
        assert_equal 0, errata.select{|p| p.errata_id == should_not_include}.count
        assert_equal 0, packages.select{|p| p.name == should_not_include_pkg}.count
      ensure
        view.destroy if view
      end
    end
  end

  private

  def vcr_perform(name)
    VCR.use_cassette("scenarios/#{name}", :match_requests_on => [:path, :params, :method, :body_json]) do
      yield
    end
  end

  def add_filter(definition, products, repos, content_type, inclusion, params)
    filter = Filter.create!(:content_view_definition => definition, :name => "publish_#{rand(999)}")
    repos.each{|repo| filter.repositories << repo}
    products.each{|product| filter.products << product}
    filter.save!
    attrs = {:filter => filter, :parameters => params.with_indifferent_access, :inclusion => inclusion}
    rule = FilterRule.create_for(content_type, attrs)
    rule.parameters = params.with_indifferent_access
    rule.save!
    rule
  end

end
