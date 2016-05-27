require 'katello_test_helper'
require 'helpers/repo_test_data'

module Katello
  describe Product do
    include OrchestrationHelper
    include ProductHelperMethods
    include OrganizationHelperMethods

    before(:each) do
      load "#{Katello::Engine.root}/spec/helpers/product_test_data.rb"
      disable_org_orchestration
      disable_product_orchestration

      as_admin do
        @organization = get_organization
      end

      @provider = Provider.where(:name => "customprovider", :organization => @organization, :provider_type => Provider::CUSTOM).first_or_create
      @cdn_mock = Resources::CDN::CdnResource.new("https://cdn.redhat.com", :ssl_client_cert => "456", :ssl_ca_file => "fake-ca.pem", :ssl_client_key => "123")
      @substitutor_mock = Util::CdnVarSubstitutor.new(@cdn_mock)
      @substitutor_mock.stubs(:precalculate).returns do |_paths|
        # we pretend, that all paths are substituted to themseves
        @substitutor_mock.instance_variable_set("@substitutions", Hash.new { |_h, k| {{} => k} })
      end
      @cdn_mock.stubs(:substitutor).returns(@substitutor_mock)

      Resources::CDN::CdnResource.stubs(:new).returns(@cdn_mock)
      disable_cdn

      ProductTestData::SIMPLE_PRODUCT.merge!(:provider => @provider)
      ProductTestData::SIMPLE_PRODUCT_WITH_INVALID_NAME.merge!(:provider => @provider)
      ProductTestData::PRODUCT_WITH_ATTRS.merge!(:provider => @provider, :organization => @organization)
      ProductTestData::PRODUCT_WITH_CONTENT.merge!(:provider => @provider, :organiation => @organization)
      ProductTestData::PRODUCT_WITH_CP_CONTENT.merge!(:provider => @provider, :organization => @organization)
    end

    describe "lazily-loaded attributes" do
      before(:each) do
        Resources::Candlepin::Product.stubs(:get).returns([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [])])
        Resources::Candlepin::Product.stubs(:create).returns(:id => ProductTestData::PRODUCT_ID)
        @p = Product.create!(
                               :label => "Zanzibar#{rand 10**6}",
                               :name => ProductTestData::PRODUCT_NAME,
                               :id => ProductTestData::PRODUCT_ID,
                               :productContent => [],
                               :provider => @provider,
                               :organization => @organization
        )
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

      specify { Product.new(:label => "goo", :name => 'contains /', :provider => @provider).must_be :valid? }
      specify { Product.new(:label => "boo", :name => 'contains #', :provider => @provider).must_be :valid? }
      specify { Product.new(:label => "shoo", :name => 'contains space', :provider => @provider).must_be :valid? }
      specify { Product.new(:label => "bar foo", :name => "foo", :provider => @provider).wont_be :valid? }
      it "should not be successful when creating a product with a duplicate name in one organization" do
        @p = Product.create!(ProductTestData::SIMPLE_PRODUCT.merge(:organization_id => @organization.id))

        Product.new(:name => @p.name, :label => @p.name,
                    :id => @p.cp_id,
                    :productContent => @p.productContent,
                    :provider => @p.provider
                   ).wont_be :valid?
      end
    end

    describe "product repos" do
      before(:each) do
        disable_product_orchestration
        Katello.pulp_server.extensions.repository.stubs(:publish_all).returns([])
      end

      describe "repo id" do
        before do
          Resources::Candlepin::Product.stubs(:create).returns(:id => ProductTestData::PRODUCT_ID)
          @p = Product.create!(ProductTestData::SIMPLE_PRODUCT.merge(:organization_id => @organization.id))
        end

        specify "format" do
          @p.repo_id('123', 'root').must_equal("#{@organization.label}-root-#{ProductTestData::SIMPLE_PRODUCT[:label]}-123")
        end

        it "should be the same as content id for cloned repository" do
          @p.repo_id("#{@organization.label}-root-#{ProductTestData::SIMPLE_PRODUCT[:label]}-123").must_equal("#{@organization.label}-root-#{ProductTestData::SIMPLE_PRODUCT[:label]}-123")
        end
      end
    end

    describe "#environments" do
      it "should contain a unique list of environments" do
        disable_repo_orchestration
        product = Product.create!(ProductTestData::SIMPLE_PRODUCT.merge(:organization_id => @organization.id))
        2.times do
          create(:katello_repository, product: product, environment: @organization.library,
                                      content_view_version: @organization.library.default_content_view_version,
                                      url: "http://something")
        end
        product.repositories.length.must_equal(2)
        product.repositories.map(&:environment).length.must_be(:>, product.environments.length)
        product.repositories.map(&:environment).uniq.length.must_equal(product.environments.length)
        product.environments.map(&:id).must_equal([@organization.library.id])
      end
    end

    it 'should be destroyable' do
      disable_repo_orchestration
      product = create(:katello_product, :fedora, provider: create(:katello_provider), organization: @organization)
      assert product.destroy
    end
  end
end
