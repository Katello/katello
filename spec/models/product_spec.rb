#
# Copyright 2011 Red Hat, Inc.
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


describe Product do

  include OrchestrationHelper
  include AuthorizationHelperMethods
  include ProductHelperMethods

  before(:each) do
    disable_org_orchestration

    @organization = Organization.create!(:name => ProductTestData::ORG_ID, :cp_key => 'admin-org-37070')
    @provider     = @organization.redhat_provider
    @substitutor_mock = CDN::CdnVarSubstitutor.new("https://cdn.redhat.com", {:ssl_client_cert => "456",:ssl_ca_file => "fake-ca.pem", :ssl_client_key => "123"})
    @substitutor_mock.stub!(:precalculate).and_return do |paths|
      # we pretend, that all paths are substituted to themseves
      @substitutor_mock.instance_variable_set("@substitutions", Hash.new {|h,k| {{} => k} })
    end

    CDN::CdnVarSubstitutor.stub(:new => @substitutor_mock)
    disable_cdn

    ProductTestData::SIMPLE_PRODUCT.merge!({:provider => @provider, :environments => [@organization.library]})
    ProductTestData::SIMPLE_PRODUCT_WITH_INVALID_NAME.merge!({:provider => @provider, :environments => [@organization.library]})
    ProductTestData::PRODUCT_WITH_ATTRS.merge!({:provider => @provider, :environments => [@organization.library]})
    ProductTestData::PRODUCT_WITH_CONTENT.merge!({:provider => @provider, :environments => [@organization.library]})
    ProductTestData::PRODUCT_WITH_CP_CONTENT.merge!({:provider => @provider, :environments => [@organization.library]})
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
      specify { @p.environments.should include(@organization.library) }
    end

    context "candlepin orchestration" do
      before do
        Candlepin::Product.stub!(:certificate).and_return("")
        Candlepin::Product.stub!(:key).and_return("")
        Pulp::Repository.stub!(:create).and_return([])
      end

      context "with attributes" do
        it "should create product in katello" do

          expected_product = {
              :attributes => ProductTestData::PRODUCT_WITH_ATTRS[:attributes],
              :multiplier => ProductTestData::PRODUCT_WITH_ATTRS[:multiplier],
              :name => ProductTestData::PRODUCT_WITH_ATTRS[:name]
          }

          Candlepin::Product.should_receive(:create).once.with(hash_including(expected_product)).and_return({:id => 1})
          product = Product.create!(ProductTestData::PRODUCT_WITH_ATTRS)
          product.organization.should_not be_nil
        end
      end

    end
  end

  context "lazily-loaded attributes" do
    before(:each) do
      Candlepin::Product.stub!(:get).and_return([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [])])
      Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
      @p = Product.create!({
        :name => ProductTestData::PRODUCT_NAME,
        :id => ProductTestData::PRODUCT_ID,
        :productContent => [],
        :provider => @provider,
        :environments => [@organization.library]
      })
    end

    it "should retrieve Product from candlepin" do
      Candlepin::Product.should_receive(:get).once.with(ProductTestData::PRODUCT_ID).and_return([ProductTestData::SIMPLE_PRODUCT])
      @p.multiplier
    end

    it "should initialize lazily-loaded attributes" do
      @p.multiplier.should == ProductTestData::SIMPLE_PRODUCT[:multiplier]
    end

    it "should replace 'attributes' with 'attrs'" do
      Candlepin::Product.stub!(:get).and_return([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [{:name => 'blah'}])])
      @p.attrs.should_not be_nil
    end

    context "arch attribute" do
      it "should be no_arch if arch attribute is not present" do
        @p.arch.should == @p.default_arch
      end

      it "should have the value of 'arch' attribute" do
        Candlepin::Product.stub!(:get).and_return([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [{:name => 'arch', :value => 'i386'}])])
        @p.arch.should == 'i386'
      end
    end

    it "should receive valid certificate" do
      Candlepin::Product.stub!(:certificate).and_return("---SOME CERT---")
      @p.certificate.should == "---SOME CERT---"
    end

    it "should receive valid key from candlepin" do
      Candlepin::Product.stub!(:key).and_return("---SOME KEY---")
      @p.key.should == "---SOME KEY---"
    end
  end

  context "validation" do
    before(:each) do
      disable_product_orchestration
    end

    specify { Product.new(:name => 'contains /', :environments => [@organization.library], :provider => @provider).should_not be_valid }
    specify { Product.new(:name => 'contains #', :environments => [@organization.library], :provider => @provider).should_not be_valid }
    specify { Product.new(:name => 'contains space', :environments => [@organization.library], :provider => @provider).should be_valid }

    it "should throw an exception when creating a product with duplicate name in one organization" do
      @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)

      Product.new({
        :name => @p.name,
        :id => @p.cp_id,
        :productContent => @p.productContent,
        :provider => @p.provider,
        :environments => @p.environments
      }).should_not be_valid
    end
  end

  context "product repos" do
    before(:each) do
      disable_product_orchestration
    end

    context "repo id" do
      before do
        Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
        @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)
      end

      specify "format" do
        @p.repo_id('123', 'root').should == "#{ProductTestData::ORG_ID}-root-#{ProductTestData::SIMPLE_PRODUCT[:name]}-123"
      end

      it "should be the same as content id for cloned repository" do
        @p.repo_id("#{ProductTestData::ORG_ID}-root-#{ProductTestData::SIMPLE_PRODUCT[:name]}-123").should == "#{ProductTestData::ORG_ID}-root-#{ProductTestData::SIMPLE_PRODUCT[:name]}-123"
      end
    end

    describe "add repo" do
      before(:each) do
        Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
        Candlepin::Content.stub!(:create).and_return({:id => "123"})
        Pulp::Repository.stub!(:update).and_return({:id => "123"})
        @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)
      end

      context "when there is a repo with the same name for the product" do
        before do
          @repo_name = "repo"
          @p.add_repo(@repo_name, "http://test/repo","yum" )
        end

        it "should raise conflict error" do
          lambda { @p.add_repo("repo", "http://test/repo","yum") }.should raise_error(Errors::ConflictException)
        end
      end
    end

    context "when importing product from candlepin" do
      before do
        Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
        Candlepin::Product.stub!(:remove_content).and_return({})
        Candlepin::Content.stub!(:create).and_return({:id => "123"})

        #@p = Product.create!(ProductTestData::SIMPLE_PRODUCT)
        #@key = EnvironmentProduct.find_or_create(@organization.library, @p)
        #@repo = Repository.create!(:pulp_id => '123' , :environment_product => key)
      end

      it "should preserve repository metadata" do
        Repository.should_receive(:create!).once.with(hash_including(:name => 'some-name33', :preserve_metadata => true, :content_type => "yum"))
        Glue::Candlepin::Product.import_from_cp(ProductTestData::PRODUCT_WITH_CP_CONTENT)
      end

      context "marketing product" do
        let(:eng_product_after_import) do
          product = Product.new(ProductTestData::PRODUCT_WITH_CP_CONTENT.merge("id" => "20", "name" => "Red Hat Enterprise Server 6")) do |p|
            p.provider = @provider
            p.environments << @organization.library
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
          env_product = mock_model(EnvironmentProduct, {:id => 1})
          EnvironmentProduct.stub(:find_or_create).and_return(env_product)

          @product = Product.new(ProductTestData::PRODUCT_WITH_CONTENT)
          @product.orchestration_for = :import_from_cp
        end

        it "should determine major and minor version of the product" do
          Repository.should_receive(:create!).once.with(hash_including(:major => 6, :minor => '6Server'))
          Repository.should_receive(:create!).once.with(hash_including(:major => 6, :minor => '6.0'))
          Repository.should_receive(:create!).once.with(hash_including(:major => 6, :minor => '6.1'))
          @product.save!
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

          env_product = mock_model(EnvironmentProduct, {:id => 1})
          EnvironmentProduct.stub(:find_or_create).and_return(env_product)

          p = Product.new(ProductTestData::PRODUCT_WITH_CONTENT)
          p.stub(:attrs => [{:name => 'arch', :value => 'x86_64,i386'}])
          p.orchestration_for = :import_from_cp
          p.save!
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

  context "package filter" do
    FILTER1_ID = 'filter1'
    FILTER2_ID = 'filter2'
    PACKAGE_LIST_1 = ['pckg1', 'pckg2']
    PACKAGE_LIST_2 = ['pckg3', 'pckg4', 'pckg5']

    before(:each) do
      disable_product_orchestration
      disable_repo_orchestration
      disable_filter_orchestration

      @environment1 = KTEnvironment.create!(:name => 'dev', :library => false, :prior => @organization.library, :organization => @organization)
      @environment2 = KTEnvironment.create!(:name => 'prod', :library => false, :prior => @environment1, :organization => @organization)

      @filter1 = Filter.create!(:name => FILTER1_ID, :package_list => PACKAGE_LIST_1, :organization => @organization)
      @filter2 = Filter.create!(:name => FILTER2_ID, :package_list => PACKAGE_LIST_2, :organization => @organization)

      Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
      Candlepin::Content.stub!(:create).and_return({:id => ProductTestData::PRODUCT_WITH_CONTENT[:productContent][0].content.id})

      @product = Product.create!(ProductTestData::PRODUCT_WITH_CONTENT)

      ep = EnvironmentProduct.find_or_create(@environment1, @product)

      @repo = Repository.create!(RepoTestData::REPO_PROPERTIES.merge(
           :environment_product => ep,
           :clone_ids => [],
           :groupid => Glue::Pulp::Repos.groupid(@product, @product.library)
      ))
      @repo.stub!(:is_cloned_in?).and_return(false)
      @repo.stub!(:clone_id).and_return("cloned_repo")

      Glue::Pulp::Repos.stub!(:clone_repo_path).and_return("cloned_path")

      @product.stub!(:repos).and_return([@repo])
    end


    it "should get persisted in filter-product association on addition" do
      @product.filters += [@filter1, @filter2]

      p = Product.find(@product.id)
      p.filters.should include(@filter1)
      p.filters.should include(@filter2)

      @filter1.products.should include(@product)
      @filter2.products.should include(@product)
    end

    it "should get removed from filter-product association on removal" do
      @product.filters += [@filter1, @filter2]
      @product.filters -= [@filter1]

      p = Product.find(@product.id)
      p.filters.size.should == 1
      p.filters.should include(@filter2)

      @filter1.products.should be_empty
      @filter2.products.should include(@product)
    end

    context "adding to a product being promoted" do
      before(:each) do
        Pulp::Repository.stub(:packages).and_return([])
        Pulp::Repository.stub(:errata).and_return([])

        @product.filters += [@filter1, @filter2]
      end

      it "should get applied during repositories cloning" do
        Pulp::Repository.should_receive(:clone_repo).once.with(anything, anything, anything, @product.filters.collect(&:pulp_id)).and_return([])
        @product.promote @organization.library, @environment1
      end

      it "should get applied to the first environment only" do
        Pulp::Repository.should_receive(:clone_repo).once.with(anything, anything, anything, []).and_return([])
        @product.promote @environment1, @environment2
      end
    end

    context "adding to/removing from an already promoted product" do
      before(:each) do
        @product.filters += [@filter1]
        @product.environments << @environment2
        @product.stub!(:promoted_to?).and_return(true)
      end

      it "should get applied to the repositories" do
        @repo.should_receive(:set_filters).once.with([@filter2.pulp_id]).and_return(true)
        @product.filters += [@filter2]
        @product.save!
      end

      it "should get removed from repositories" do
        @repo.should_receive(:del_filters).once.with([@filter1.pulp_id]).and_return(true)
        @product.filters -= [@filter1]
      end
    end
  end


  describe "product permission tests" do
    before (:each) do
      disable_product_orchestration
      disable_repo_orchestration

      User.current = superadmin
      @product = Product.new({:name => "prod"})
      @product.provider = @organization.redhat_provider
      @product.environments << @organization.library
      @product.stub(:arch).and_return('noarch')
      @product.save!
      @ep = EnvironmentProduct.find_or_create(@organization.library, @product)
      @repo = Repository.create!(:environment_product => @ep, :name => "testrepo",:pulp_id=>"1010")
      @repo.stub(:promoted?).and_return(false)
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
      @product = Product.new({:name => "prod#{suffix}"})
      @product.provider = @provider
      @product.environments << @organization.library
      @product.stub(:arch).and_return('noarch')
      @product.save!

      @ep = EnvironmentProduct.find_or_create(@organization.library, @product)
      @repo = Repository.create!(:environment_product => @ep,
                                 :name => "testrepo",
                                 :pulp_id=>"1010",
                                 :relative_path => "#{@organization.name}/library/Prod/Repo")
      @repo.stub(:promoted?).and_return(false)
      @repo.stub(:content => {:id => "123"})
    end
    context "resetting product gpg and asking repos to reset should work" do
      before do
        @product.update_attributes!(:gpg_key => @gpg)
        @product.reset_repo_gpgs!
      end
      subject {Repository.find(@repo.id)}
      its(:gpg_key){should == @gpg}
    end

    context "resetting product gpg work across multiple environments" do
      before do
        Pulp::Repository.stub(:packages).and_return([])
        Pulp::Repository.stub(:errata).and_return([])
        @env = KTEnvironment.create!(:name => "new_repo", :organization =>@organization, :prior=>@organization.library)
        @new_repo = promote(@repo, @env)
        @product = Product.find(@product.id)
        @product.update_attributes!(:gpg_key => @gpg)
        @product.reset_repo_gpgs!
      end
      subject {Repository.find(@new_repo.id)}
      its(:gpg_key){should == @gpg}
    end

    context "resetting product gpg to nil should also nil out repos under it" do
      before do
        @product.update_attributes!(:gpg_key => @gpg)
        @product.reset_repo_gpgs!
        @product.update_attributes!(:gpg_key => nil)
        @product.reset_repo_gpgs!
      end
      subject {Repository.find(@repo.id)}
      its(:gpg_key){should be_nil}
    end


  end
end
