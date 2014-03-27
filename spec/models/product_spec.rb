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
require 'helpers/repo_test_data'

module Katello
describe Product, :katello => true do

  include OrchestrationHelper
  include AuthorizationHelperMethods
  include ProductHelperMethods
  include OrganizationHelperMethods

  before(:each) do
    load "#{Katello::Engine.root}/spec/helpers/product_test_data.rb"
    disable_org_orchestration
    disable_product_orchestration

    as_admin do
      User.current.stubs(:remote_id).returns(User.current.login)
      @organization = Organization.find_or_create_by_label!(:name=>ProductTestData::ORG_ID, :label => 'admin-org-37070')
    end

    @provider     = Provider.find_or_create_by_name!(:name=>"customprovider", :organization=>@organization, :provider_type=>Provider::CUSTOM)
    @cdn_mock = Resources::CDN::CdnResource.new("https://cdn.redhat.com", {:ssl_client_cert => "456",:ssl_ca_file => "fake-ca.pem", :ssl_client_key => "123"})
    @substitutor_mock = Util::CdnVarSubstitutor.new(@cdn_mock)
    @substitutor_mock.stubs(:precalculate).returns do |paths|
      # we pretend, that all paths are substituted to themseves
      @substitutor_mock.instance_variable_set("@substitutions", Hash.new {|h,k| {{} => k} })
    end
    @cdn_mock.stubs(:substitutor).returns(@substitutor_mock)

    Resources::CDN::CdnResource.stubs(:new).returns(@cdn_mock)
    disable_cdn

    ProductTestData::SIMPLE_PRODUCT.merge!({:provider => @provider})
    ProductTestData::SIMPLE_PRODUCT_WITH_INVALID_NAME.merge!({:provider => @provider})
    ProductTestData::PRODUCT_WITH_ATTRS.merge!({:provider => @provider})
    ProductTestData::PRODUCT_WITH_CONTENT.merge!({:provider => @provider})
    ProductTestData::PRODUCT_WITH_CP_CONTENT.merge!({:provider => @provider})
  end

  describe "lazily-loaded attributes" do
    before(:each) do
      Resources::Candlepin::Product.stubs(:get).returns([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [])])
      Resources::Candlepin::Product.stubs(:create).returns({:id => ProductTestData::PRODUCT_ID})
      @p = Product.create!({
        :label => "Zanzibar#{rand 10**6}",
        :name => ProductTestData::PRODUCT_NAME,
        :id => ProductTestData::PRODUCT_ID,
        :productContent => [],
        :provider => @provider
      })
    end

    it "should retrieve Product from candlepin" do
      Resources::Candlepin::Product.expects(:get).once.returns([ProductTestData::SIMPLE_PRODUCT])
      @p.multiplier
    end

    it "should initialize lazily-loaded attributes" do
      @p.multiplier.must_equal(ProductTestData::SIMPLE_PRODUCT[:multiplier])
    end

    it "should replace 'attributes' with 'attrs'" do
      Resources::Candlepin::Product.stubs(:get).returns([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [{:name => 'blah'}])])
      @p.attrs.wont_be_nil
    end

    describe "arch attribute" do
      it "should be no_arch if arch attribute is not present" do
        @p.arch.must_equal(@p.default_arch)
      end

      it "should have the value of 'arch' attribute" do
        Resources::Candlepin::Product.stubs(:get).returns([ProductTestData::SIMPLE_PRODUCT.merge(:attrs => [{:name => 'arch', :value => 'i386'}])])
        Product.find(@p.id).arch.must_equal('i386')
      end
    end

    it "should receive valid certificate" do
      Resources::Candlepin::Product.stubs(:certificate).returns("---SOME CERT---")
      @p.certificate.must_equal("---SOME CERT---")
    end

    it "should receive valid key from candlepin" do
      Resources::Candlepin::Product.stubs(:key).returns("---SOME KEY---")
      @p.key.must_equal("---SOME KEY---")
    end
  end

  describe "validation" do
    before(:each) do
      disable_product_orchestration
    end

    specify { Product.new(:label=> "goo", :name => 'contains /', :provider => @provider).must_be :valid? }
    specify { Product.new(:label=>"boo", :name => 'contains #', :provider => @provider).must_be :valid? }
    specify { Product.new(:label=> "shoo", :name => 'contains space', :provider => @provider).must_be :valid? }
    specify { Product.new(:label => "bar foo", :name=> "foo", :provider => @provider).wont_be :valid?}
    it "should not be successful when creating a product with a duplicate name in one organization" do
      @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)

      Product.new({:name=>@p.name, :label=> @p.name,
        :id => @p.cp_id,
        :productContent => @p.productContent,
        :provider => @p.provider
      }).wont_be :valid?
    end
  end

  describe "product repos" do
    before(:each) do
      disable_product_orchestration
      Katello.pulp_server.extensions.repository.stubs(:publish_all).returns([])
      Repository.any_instance.stubs(:publish_distributor)
    end

    describe "repo id" do
      before do
        Resources::Candlepin::Product.stubs(:create).returns({:id => ProductTestData::PRODUCT_ID})
        @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)
      end

      specify "format" do
        @p.repo_id('123', 'root').must_equal("#{ProductTestData::ORG_ID}-root-#{ProductTestData::SIMPLE_PRODUCT[:label]}-123")
      end

      it "should be the same as content id for cloned repository" do
        @p.repo_id("#{ProductTestData::ORG_ID}-root-#{ProductTestData::SIMPLE_PRODUCT[:label]}-123").must_equal("#{ProductTestData::ORG_ID}-root-#{ProductTestData::SIMPLE_PRODUCT[:label]}-123")
      end
    end

    describe "add repo" do
      before(:each) do
        Resources::Candlepin::Product.stubs(:create).returns({:id => ProductTestData::PRODUCT_ID})
        Resources::Candlepin::Content.stubs(:create).returns({:id => "123", :type=>'yum'})
        Resources::Candlepin::Content.stubs(:update).returns({:id => "123", :type=>'yum'})
        Resources::Candlepin::Content.stubs(:get).returns({:id => "123", :type=>'yum'})
        Repository.any_instance.stubs(:generate_metadata)
        @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)
      end

      describe "when there is a repo with the same name for the product" do
        before do
          @repo_name = "repo"
          @repo_label = "repo"
          disable_repo_orchestration
          @p.add_repo(@repo_label, @repo_name, "http://test/repo","yum").save!
        end

        it "should raise conflict error" do
          lambda {@p.add_repo(@repo_label, @repo_name, "http://test/repo","yum")}.must_raise(
              Errors::ConflictException)
        end
      end
    end

    describe "when importing product from candlepin" do

      describe "marketing product" do
        let(:eng_product_after_import) do
          product = Product.new(ProductTestData::PRODUCT_WITH_CP_CONTENT.merge("id" => "20", "name" => "Red Hat Enterprise Server 6")) do |p|
            p.provider = @provider
          end
          product.orchestration_for = :import_from_cp_ar_setup
          product.save!
          product
        end

        subject { Glue::Candlepin::Product.import_marketing_from_cp(ProductTestData::PRODUCT_WITH_CP_CONTENT, [eng_product_after_import.id]) }

        specify "repositories should not get created for that" do
          Repository.expects(:create!).never
          subject
        end

        it { subject.engineering_products.must_equal([eng_product_after_import]) }

        it { subject.must_be_kind_of(MarketingProduct) }
      end

      describe "product major/minor versions" do
        before do
          disable_product_orchestration
          @substitutor_mock.stubs(:precalculate).returns do |paths|
            ret = {}
            paths.each do |path|
              path = path[/^.*\$\w+/]
              path_substitutions = {}
              [ {"releasever" => "6Server", "basearch" => "x86_64"},
                {"releasever" => "6.0", "basearch" => "x86_64"},
                {"releasever" => "6.1", "basearch" => "x86_64"}].each do |substitutions|
                path_substitutions[substitutions] = substitutions.inject(path) {|new_path,(var,val)| new_path.gsub("$#{var}", val)}
              end
              ret[path] = path_substitutions
            end
            @substitutor_mock.instance_variable_set("@substitutions", ret)
          end

          @product = Product.new(ProductTestData::PRODUCT_WITH_CONTENT)
          @product.orchestration_for = :import_from_cp

          @product.productContent.each{|pc| pc.product = @product} #fake pc can't easily keep track of its product
          Resources::CDN::CdnResource.any_instance.stubs(:get).returns({})
          Resources::CDN::CdnResource.any_instance.stubs(:new).returns(mock("Substitutor").stubs(:substitutor).returns(@substitutor_mock))
        end

        it "should determine major and minor version of the product" do
          skip
          Repository.expects(:create!).once.with(:major => 6, :minor => '6Server')
          Repository.expects(:create!).once.with(:major => 6, :minor => '6.0')
          Repository.expects(:create!).once.with(:major => 6, :minor => '6.1')
          @product.productContent.first.refresh_repositories
        end
      end

      describe "product has more archs" do
        before do
          disable_product_orchestration

          @product = Product.new(ProductTestData::PRODUCT_WITH_CONTENT.merge(:provider => @provider))
          @product.stubs(:attrs => [{:name => 'arch', :value => 'x86_64,i386'}])
          @product.orchestration_for = :import_from_cp
          @product.productContent.each { |pc| pc.product = @product } #fake pc can't easily keep track of its product
          @product.save!

          @substitutor_mock.stubs(:substitute_vars).with(@product.productContent.first.content.contentUrl).returns([
            [{'basearch' => 'i386', 'releasever' => '6Server'},
              "#{@organization.name}/released-extra/RHEL-5-Server/6Server/i386/os/ClusterStorage"],
            [{'basearch' => 'x86_64', 'releasever' => '6Server'},
              "#{@organization.name}/released-extra/RHEL-5-Server/6Server/x86_64/os/ClusterStorage"]
          ])

          Resources::CDN::CdnResource.any_instance.stubs(:new).returns(mock("Substitutor").stubs(:substitutor).returns(@substitutor_mock))
        end

        describe "repository for product content" do
          it "should be created for each arch" do
            skip
            expected_feed = "#{@organization.name}/released-extra/RHEL-5-Server/6Server/x86_64/os/ClusterStorage"
            Repository.expects(:create!).once.with(:feed => expected_feed, :name => 'some-name33 x86_64 6Server')
            Repository.expects(:create!).once.with(:name => 'some-name33 i386 6Server')
            @product.productContent.first.refresh_repositories
          end

          it "should follow the format of the content url in candlepin" do
            skip
            expected_relative_path = "#{@organization.name}/Library/released-extra/RHEL-5-Server/6Server/x86_64/os/ClusterStorage"
            Repository.expects(:create!).once.with(:relative_path => expected_relative_path)
            @product.productContent.first.refresh_repositories
          end
        end
      end
    end
  end

  describe "product permission tests" do
    before (:each) do
      disable_product_orchestration
      disable_repo_orchestration

      User.current = superadmin
      @product = Product.new({:name=>"prod", :label=> "prod"})
      @product.provider = @organization.redhat_provider
      @product.stubs(:arch).returns('noarch')
      @product.save!
      Repository.any_instance.stubs(:create_pulp_repo).returns({})
      @repo = Repository.create!(:product => @product,
                                 :environment => @organization.library,
                                 :name => "testrepo",
                                 :label => "testrepo_label", :pulp_id=>"1010",
                                 :content_id=>'123', :relative_path=>"/foo/",
                                 :content_view_version=>@organization.library.default_content_view_version,
                                 :feed => 'https://localhost')
      @repo.stubs(:promoted?).returns(false)
      @repo.stubs(:update_content).returns(Candlepin::Content.new)
    end

    describe "Test list enabled repos should show redhat repos" do
      before do
        @repo.enabled = false
        @repo.save!
      end

      specify {Product.readable(@organization).must_be_empty}
      subject {Product.all_readable(@organization)}
      it { subject.wont_be_empty }
      it { subject.must_equal([@product]) }
      specify {Product.editable(@organization).must_be_empty}
      specify {Product.syncable(@organization).must_be_empty}
    end

    describe "readable and syncable" do
      before do
        @repo.enabled = true
        @repo.save!
      end

      specify { Product.readable(@organization).must_equal([@product]) }
      specify { Product.syncable(@organization).must_equal([@product]) }
    end
  end

  describe "product reset repo gpgs test" do
    before do
      disable_product_orchestration
      disable_repo_orchestration

      suffix = (rand 10 **6).to_s
      test_gpg_content = File.open("#{Katello::Engine.root}/spec/assets/gpg_test_key").read
      @gpg = GpgKey.create!(:name =>"GPG", :organization=>@organization, :content=>test_gpg_content)
      @provider = Provider.create!({:organization =>@organization, :name => 'provider' + suffix,
                              :repository_url => "https://something.url", :provider_type => Provider::CUSTOM})
      @product = Product.new({:name=>"prod#{suffix}", :label=> "prod#{suffix}"})
      @product.provider = @provider
      @product.stubs(:arch).returns('noarch')
      @product.save!

      @repo = Repository.create!(:environment => @organization.library,
                                 :product => @product,
                                 :name => "testrepo",
                                 :label => "testrepo_label",
                                 :pulp_id=>"1010",
                                 :content_id=>"123",
                                 :relative_path => "#{@organization.name}/library/Prod/Repo",
                                 :content_view_version=>@organization.library.default_content_view_version,
                                 :feed => 'https://localhost')
      @repo.stubs(:product).returns(@product)
      @repo.stubs(:promoted?).returns(false)
      @repo.stubs(:update_content).returns(Candlepin::Content.new)
    end

    describe "resetting product gpg and asking repos to reset should work" do
      before do
        #@product.expects(:refresh_content).once
        @product.update_attributes!(:gpg_key => @gpg)
        @product.reset_repo_gpgs!
      end

      subject { Repository.find(@repo.id) }
      it { subject.gpg_key.must_equal(@gpg) }
    end

    describe "resetting product gpg work across multiple environments" do
      before do
        @env = create_environment(:name=>"new_repo", :label=> "new_repo", :organization =>@organization, :prior=>@organization.library)
        @new_repo = promote(@repo, @env)
        @new_repo.stubs(:content).returns(OpenStruct.new(:id=>"adsf", :gpgUrl=>'http://foo'))
        @repo.stubs(:content).returns(OpenStruct.new(:id=>"adsf", :gpgUrl=>''))

        @product = Product.find(@product.id)
        @new_repo.stubs(:product).returns(@product)
        @repo.stubs(:product).returns(@product)
        @repo.stubs(:update_content).returns(Candlepin::Content.new)
        @new_repo.stubs(:update_content).returns(Candlepin::Content.new)

        #@product.expects(:refresh_content).once
        @product.stubs(:repositories).returns([@new_repo, @repo])

        @product.update_attributes!(:gpg_key => @gpg)
        @product.reset_repo_gpgs!
      end
      subject {Repository.find(@new_repo.id)}
      it { subject.gpg_key.must_equal(@gpg) }
    end

    describe "resetting product gpg to nil should also nil out repos under it" do
      before do
        #@product.expects(:refresh_content).twice
        @product.update_attributes!(:gpg_key => @gpg)
        @product.reset_repo_gpgs!

        @product.repositories.first.expects(:update_content).returns(Candlepin::Content.new)
        @product.update_attributes!(:gpg_key => nil)
        @product.reset_repo_gpgs!
      end
      subject {Repository.find(@repo.id)}
      it { subject.gpg_key.must_be_nil }
    end
  end

  describe "#environments" do
    it "should contain a unique list of environments" do
      disable_repo_orchestration
      product = Product.create!(ProductTestData::SIMPLE_PRODUCT)
      2.times do
        create(:katello_repository, product: product, environment: @organization.library,
               content_view_version: @organization.library.default_content_view_version,
               feed: "http://something")
      end
      product.repositories.length.must_equal(2)
      product.repositories.map(&:environment).length.must_be(:>, product.environments.length)
      product.repositories.map(&:environment).uniq.length.must_equal(product.environments.length)
      product.environments.map(&:id).must_equal([@organization.library.id])
    end
  end

  it 'should be destroyable' do
    disable_repo_orchestration
    product = create(:katello_product, :fedora, provider: create(:katello_provider, organization: @organization))
    assert product.destroy
  end
end
end
