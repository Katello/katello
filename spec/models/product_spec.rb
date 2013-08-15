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

require 'spec_helper'
require 'helpers/product_test_data'
require 'helpers/repo_test_data'

describe Product, :katello => true do

  include OrchestrationHelper
  include AuthorizationHelperMethods
  include ProductHelperMethods

  before(:each) do
    disable_org_orchestration
    disable_product_orchestration
    @organization = Organization.create!(:name=>ProductTestData::ORG_ID, :label => 'admin-org-37070')
    @provider     = Provider.create!(:name=>"customprovider", :organization=>@organization, :provider_type=>Provider::CUSTOM)
    @cdn_mock = Resources::CDN::CdnResource.new("https://cdn.redhat.com", {:ssl_client_cert => "456",:ssl_ca_file => "fake-ca.pem", :ssl_client_key => "123"})
    @substitutor_mock = Util::CdnVarSubstitutor.new(@cdn_mock)
    @substitutor_mock.stub!(:precalculate).and_return do |paths|
      # we pretend, that all paths are substituted to themseves
      @substitutor_mock.instance_variable_set("@substitutions", Hash.new {|h,k| {{} => k} })
    end
    @cdn_mock.stub(:substitutor => @substitutor_mock)

    Resources::CDN::CdnResource.stub(:new => @cdn_mock)
    disable_cdn

    ProductTestData::SIMPLE_PRODUCT.merge!({:provider => @provider})
    ProductTestData::SIMPLE_PRODUCT_WITH_INVALID_NAME.merge!({:provider => @provider})
    ProductTestData::PRODUCT_WITH_ATTRS.merge!({:provider => @provider})
    ProductTestData::PRODUCT_WITH_CONTENT.merge!({:provider => @provider})
    ProductTestData::PRODUCT_WITH_CP_CONTENT.merge!({:provider => @provider})
  end

  describe "create product" do

    context "new product" do
      before(:each) { @p = Product.new({}) }
      specify { @p.productContent.should == [] }
    end

    context "with valid parameters" do
      before(:each) do
        disable_product_orchestration
        @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)
      end

      specify { @p.name.should == ProductTestData::SIMPLE_PRODUCT['name'] }
      specify { @p.created_at.should_not be_nil }
      specify { @p.library.should eql(@organization.library) }
    end

    context "candlepin orchestration" do
      before do
        Resources::Candlepin::Product.stub!(:certificate).and_return("")
        Resources::Candlepin::Product.stub!(:key).and_return("")
      end

      context "with attributes" do
        it "should create product in katello" do

          expected_product = {
              :attributes => ProductTestData::PRODUCT_WITH_ATTRS[:attributes],
              :multiplier => ProductTestData::PRODUCT_WITH_ATTRS[:multiplier],
              :name => ProductTestData::PRODUCT_WITH_ATTRS[:name]
          }

          Resources::Candlepin::Product.should_receive(:create).once.with(hash_including(expected_product)).and_return({:id => '1'})
          product = Product.create!(ProductTestData::PRODUCT_WITH_ATTRS)
          product.organization.should_not be_nil
        end
      end

    end
  end

  context "lazily-loaded attributes" do
    before(:each) do
      Resources::Candlepin::Product.stub!(:get).and_return([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [])])
      Resources::Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
      @p = Product.create!({
        :label => "Zanzibar#{rand 10**6}",
        :name => ProductTestData::PRODUCT_NAME,
        :id => ProductTestData::PRODUCT_ID,
        :productContent => [],
        :provider => @provider
      })
    end

    it "should retrieve Product from candlepin" do
      Resources::Candlepin::Product.should_receive(:get).once.with(ProductTestData::PRODUCT_ID).and_return([ProductTestData::SIMPLE_PRODUCT])
      @p.multiplier
    end

    it "should initialize lazily-loaded attributes" do
      @p.multiplier.should == ProductTestData::SIMPLE_PRODUCT[:multiplier]
    end

    it "should replace 'attributes' with 'attrs'" do
      Resources::Candlepin::Product.stub!(:get).and_return([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [{:name => 'blah'}])])
      @p.attrs.should_not be_nil
    end

    context "arch attribute" do
      it "should be no_arch if arch attribute is not present" do
        @p.arch.should == @p.default_arch
      end

      it "should have the value of 'arch' attribute" do
        Resources::Candlepin::Product.stub!(:get).and_return([ProductTestData::SIMPLE_PRODUCT.merge(:attrs => [{:name => 'arch', :value => 'i386'}])])
        Product.find(@p.id).arch.should == 'i386'
      end
    end

    it "should receive valid certificate" do
      Resources::Candlepin::Product.stub!(:certificate).and_return("---SOME CERT---")
      @p.certificate.should == "---SOME CERT---"
    end

    it "should receive valid key from candlepin" do
      Resources::Candlepin::Product.stub!(:key).and_return("---SOME KEY---")
      @p.key.should == "---SOME KEY---"
    end
  end

  context "validation" do
    before(:each) do
      disable_product_orchestration
    end

    specify { Product.new(:label=> "goo", :name => 'contains /', :provider => @provider).should be_valid }
    specify { Product.new(:label=>"boo", :name => 'contains #', :provider => @provider).should be_valid }
    specify { Product.new(:label=> "shoo", :name => 'contains space', :provider => @provider).should be_valid }
    specify { Product.new(:label => "bar foo", :name=> "foo", :provider => @provider).should_not be_valid}
    it "should be successful when creating a product with a duplicate name in one organization" do
      @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)

      Product.new({:name=>@p.name, :label=> @p.name,
        :id => @p.cp_id,
        :productContent => @p.productContent,
        :provider => @p.provider
      }).should be_valid
    end
  end

  context "product repos" do
    before(:each) do
      disable_product_orchestration
      Katello.pulp_server.extensions.repository.stub(:publish_all).and_return([])
      Repository.any_instance.stubs(:publish_distributor)
    end

    context "repo id" do
      before do
        Resources::Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
        @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)
      end

      specify "format" do
        @p.repo_id('123', 'root').should == "#{ProductTestData::ORG_ID}-root-#{ProductTestData::SIMPLE_PRODUCT[:label]}-123"
      end

      it "should be the same as content id for cloned repository" do
        @p.repo_id("#{ProductTestData::ORG_ID}-root-#{ProductTestData::SIMPLE_PRODUCT[:label]}-123").should == "#{ProductTestData::ORG_ID}-root-#{ProductTestData::SIMPLE_PRODUCT[:label]}-123"
      end
    end

    describe "add repo" do
      before(:each) do
        Resources::Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
        Resources::Candlepin::Content.stub!(:create).and_return({:id => "123", :type=>'yum'})
        Resources::Candlepin::Content.stub!(:update).and_return({:id => "123", :type=>'yum'})
        Resources::Candlepin::Content.stub!(:get).and_return({:id => "123", :type=>'yum'})
        Repository.any_instance.stub(:publish_distributor)

        @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)
      end

      context "when there is a repo with the same name for the product" do
        before do
          @repo_name = "repo"
          @repo_label = "repo"
          disable_repo_orchestration
          @p.add_repo(@repo_label, @repo_name, "http://test/repo","yum" )
        end

        it "should raise conflict error" do
          lambda { @p.add_repo(@repo_label, @repo_name, "http://test/repo","yum") }.should raise_error(Errors::ConflictException)
        end
      end
    end

    context "when importing product from candlepin" do

      context "marketing product" do
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
          Repository.should_not_receive(:create!)
          subject
        end

        its(:engineering_products) { should == [eng_product_after_import] }

        it { should be_an_instance_of MarketingProduct }
      end

      describe "product major/minor versions" do
        before do
          @substitutor_mock.stub!(:precalculate).and_return do |paths|
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
        end

        it "should determine major and minor version of the product" do
          Repository.should_receive(:create!).once.with(hash_including(:major => 6, :minor => '6Server'))
          Repository.should_receive(:create!).once.with(hash_including(:major => 6, :minor => '6.0'))
          Repository.should_receive(:create!).once.with(hash_including(:major => 6, :minor => '6.1'))
          @product.productContent.first.refresh_repositories
        end
      end

      context "product has more archs" do
        after do
          Repository.stub(:create! => true)
          @substitutor_mock.stub!(:substitute_vars).and_return do |path|
            ret = {}
            [{"releasever" => "6Server", "basearch" => "i386"},
             {"releasever" => "6Server", "basearch" => "x86_64"}].each do |substitutions|
              ret[substitutions] = substitutions.inject(path) {|new_path,(var,val)| new_path.gsub("$#{var}", val)}
             end
            ret
          end

          p = Product.new(ProductTestData::PRODUCT_WITH_CONTENT)
          p.stub(:attrs => [{:name => 'arch', :value => 'x86_64,i386'}])
          p.orchestration_for = :import_from_cp
          p.productContent.each{|pc| pc.product = p} #fake pc can't easily keep track of its product
          p.save!
          p.productContent.first.refresh_repositories
        end

        describe "repository for product content" do
          it "should be created for each arch" do
            expected_feed = "#{@provider.repository_url}/released-extra/RHEL-5-Server/6Server/x86_64/os/ClusterStorage"
            Repository.should_receive(:create!).once.with(hash_including(:feed => expected_feed, :name => 'some-name33 x86_64 6Server'))
            Repository.should_receive(:create!).once.with(hash_including(:name => 'some-name33 i386 6Server'))
          end

          it "should follow the format of the content url in candlepin" do
            expected_relative_path = "#{@organization.name}/Library/released-extra/RHEL-5-Server/6Server/x86_64/os/ClusterStorage"
            Repository.should_receive(:create!).once.with(hash_including(:relative_path => expected_relative_path))
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
      @product.stub(:arch).and_return('noarch')
      @product.save!
      @repo = Repository.create!(:product => @product,
                                 :environment => @organization.library,
                                 :name => "testrepo",
                                 :label => "testrepo_label", :pulp_id=>"1010",
                                 :content_id=>'123', :relative_path=>"/foo/",
                                 :content_view_version=>@organization.library.default_content_view_version,
                                 :feed => 'https://localhost')
      @repo.stub(:promoted?).and_return(false)
      @repo.stub(:update_content).and_return(Candlepin::Content.new)
    end
    context "Test list enabled repos should show redhat repos" do
      before do
        @repo.enabled = false
        @repo.save!
      end
      specify {Product.readable(@organization).should be_empty}
      subject {Product.all_readable(@organization)}
      it {should_not be_empty}
      it {should == [@product]}
      specify {Product.editable(@organization).should be_empty}
      specify {Product.syncable(@organization).should be_empty}

      subject {Product.all_editable(@organization)}
      it {should_not be_empty}
      it {should == [@product]}
    end

    context "Test list enabled repos should show redhat repos" do
      before do
        @repo.enabled = true
        @repo.save!
      end
      specify {Product.readable(@organization).should == [@product]}
      specify {Product.syncable(@organization).should == [@product]}
      specify {Product.editable(@organization).should == [@product]}
    end
  end

  describe "product reset repo gpgs test" do
    before do
      disable_product_orchestration
      disable_repo_orchestration

      suffix = (rand 10 **6).to_s
      @gpg = GpgKey.create!(:name =>"GPG", :organization=>@organization, :content=>"bar")
      @provider = Provider.create!({:organization =>@organization, :name => 'provider' + suffix,
                              :repository_url => "https://something.url", :provider_type => Provider::CUSTOM})
      @product = Product.new({:name=>"prod#{suffix}", :label=> "prod#{suffix}"})
      @product.provider = @provider
      @product.stub(:arch).and_return('noarch')
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
      @repo.stub(:product).and_return(@product)
      @repo.stub(:promoted?).and_return(false)
      @repo.stub(:update_content).and_return(Candlepin::Content.new)
    end

    context "resetting product gpg and asking repos to reset should work" do
      before do
        #@product.should_receive(:refresh_content).once
        @product.update_attributes!(:gpg_key => @gpg)
        @product.reset_repo_gpgs!
      end

      subject {Repository.find(@repo.id)}
      its(:gpg_key){should == @gpg}
    end

    context "resetting product gpg work across multiple environments" do
      before do
        @env = create_environment(:name=>"new_repo", :label=> "new_repo", :organization =>@organization, :prior=>@organization.library)
        @new_repo = promote(@repo, @env)
        @new_repo.stub(:content).and_return(OpenStruct.new(:id=>"adsf", :gpgUrl=>'http://foo'))
        @repo.stub(:content).and_return(OpenStruct.new(:id=>"adsf", :gpgUrl=>''))

        @product = Product.find(@product.id)
        @new_repo.stub(:product).and_return(@product)
        @repo.stub(:product).and_return(@product)
        @repo.stub(:update_content).and_return(Candlepin::Content.new)
        @new_repo.stub(:update_content).and_return(Candlepin::Content.new)

        #@product.should_receive(:refresh_content).once
        @product.stub(:repositories).and_return([@new_repo, @repo])

        @product.update_attributes!(:gpg_key => @gpg)
        @product.reset_repo_gpgs!
      end
      subject {Repository.find(@new_repo.id)}
      its(:gpg_key){should == @gpg}
    end

    context "resetting product gpg to nil should also nil out repos under it" do
      before do
        #@product.should_receive(:refresh_content).twice
        @product.update_attributes!(:gpg_key => @gpg)
        @product.reset_repo_gpgs!

        @product.repositories.first.should_receive(:update_content).and_return(Candlepin::Content.new)
        @product.update_attributes!(:gpg_key => nil)
        @product.reset_repo_gpgs!
      end
      subject {Repository.find(@repo.id)}
      its(:gpg_key){should be_nil}
    end
  end

  describe "#environments" do
    it "should contain a unique list of environments" do
      disable_repo_orchestration
      product = Product.create!(ProductTestData::SIMPLE_PRODUCT)
      2.times do
        create(:repository, product: product, environment: @organization.library,
               content_view_version: @organization.library.default_content_view_version,
               feed: "http://something")
      end
      product.repositories.length.should eql(2)
      product.repositories.map(&:environment).length.should > (product.environments.length)
      product.repositories.map(&:environment).uniq.length.should eql(product.environments.length)
      product.environments.map(&:id).should eql([@organization.library.id])
    end
  end
end
