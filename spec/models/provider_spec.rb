require 'katello_test_helper'
require 'helpers/product_test_data'

module Katello
  #rubocop:disable Metrics/BlockLength
  describe Provider do
    include OrchestrationHelper

    let(:to_create_rh) do
      {
        :name => "some name",
        :description => "a description",
        :repository_url => "https://cdn.redhat.com",
        :provider_type => Provider::REDHAT,
        :organization => @organization
      }
    end

    let(:to_create_custom) do
      {
        :name => "some name",
        :description => "a description",
        :repository_url => "http://some.url/path",
        :provider_type => Provider::CUSTOM,
        :organization => @organization
      }
    end

    before(:each) do
      disable_org_orchestration
      disable_product_orchestration
      @organization = get_organization(:organization2)
      @organization.redhat_provider.delete
    end

    describe "import_product_from_cp creates product with correct attributes" do
      before(:each) do
        Candlepin::ProductContent.stubs(:create)
        Candlepin::ProductContent.stubs(:new)
        Resources::Candlepin::Product.stubs(:create).returns(:id => "product_id")
        @provider = Provider.new(
                                   :name => 'test_provider',
                                   :repository_url => 'http://something.net',
                                   :provider_type => Provider::REDHAT,
                                   :organization => @organization
        )
        @provider.save!

        @product = Product.create!(:cp_id => "product_id", :label => "prod", :name => "prod", :productContent => [], :provider => @provider, :organization => @organization)
      end

      specify { @product.wont_be_nil }
      specify { @product.provider.must_equal(@provider) }
    end

    describe "products refresh(katello)" do
      def product_content(name)
        Candlepin::ProductContent.new(
          "content" => {
            "name" => name,
            "id" => name.hash.to_s,
            "type" => "yum",
            "label" => name,
            "vendor" => "redhat",
            "contentUrl" => "/released-extra/#{name}/$releasever/os/rpms",
            "gpgUrl" => "/some/gpg/url/",
            "updated" => "2011-01-04T18:47:47.219+0000",
            "created" => "2011-01-04T18:47:47.219+0000"},
          "enabled" => true,
          "flexEntitlement" => 0,
          "physicalEntitlement" => 0
        )
      end

      def create_product_with_content(product_name, releases)
        product = @provider.products.create!(:name => product_name, :label => "#{product_name.hash}", :cp_id => product_name.hash, :organization => @organization)

        product.productContent = [product_content(product_name)]
        product.productContent.each do |product_content|
          releases.each do |release|
            version = Resources::CDN::Utils.parse_version(release)
            repo_name = "#{product_content.content.name} #{release}"
            repo_label = repo_name.gsub(/[^-\w]/, "_")
            repo = Repository.new(:environment => product.organization.library,
                                  :product => product,
                                  :cp_label => product_content.content.label,
                                  :name => repo_name,
                                  :label => repo_label,
                                  :pulp_id => product.repo_id(repo_name),
                                  :major => version[:major],
                                  :minor => version[:minor],
                                  :relative_path => '/foo',
                                  :content_id => 'asdfasdf',
                                  :content_view_version => product.organization.library.default_content_view_version,
                                  :url => 'http://localhost')
            repo.stubs(:create_pulp_repo).returns({})
            repo.save!
          end
        end
        product
      end

      def set_upstream_releases(product, releases)
        Thread.current[:cdn_var_substitutor_cache] ||= {}
        cache = Thread.current[:cdn_var_substitutor_cache]
        product.productContent.each do |product_content|
          prefix_with_vars = product_content.content.contentUrl[/^.*\$[^\/]+/]
          cache[prefix_with_vars] = {}
          releases.each do |release|
            prefix_without_vars = prefix_with_vars.sub("$releasever", release)
            cache[prefix_with_vars][{"releasever" => release}] = prefix_without_vars
          end
        end
      end

      before do
        disable_org_orchestration
        disable_product_orchestration
        disable_cdn
        @organization = Organization.create!(:name => "org10026", :label => "org10026_key")
        @provider = @organization.redhat_provider

        @product_without_change = create_product_with_content("product-without-change", ["1.0", "1.1"])
        set_upstream_releases(@product_without_change, ["1.0", "1.1"])

        @product_with_change = create_product_with_content("product-with-change", ["1.0"])
        set_upstream_releases(@product_with_change, ["1.0", "1.1"])

        @product_without_change.productContent.each { |pc| pc.product = @product_without_change }
        @product_with_change.productContent.each { |pc| pc.product = @product_with_change }

        engineering = stub
        engineering.stubs(:engineering).returns([@product_without_change, @product_with_change])
        @provider.stubs(:products).returns(engineering)
      end

      after do
        Thread.current[:cdn_var_substitutor_cache] = nil
      end
    end

    describe "sync provider" do
      before(:each) do
        @provider = Provider.create(to_create_custom) do |p|
          p.organization = @organization
        end

        @product1 = Product.create!(:cp_id => "product1_id", :label => "prod1", :name => "product1", :productContent => [], :provider => @provider, :organization => @organization)
        @product2 = Product.create!(:cp_id => "product2_id", :label => "prod2", :name => "product2", :productContent => [], :provider => @provider, :organization => @organization)
      end

      it "should create sync for all it's products" do
        @provider.products.each do |p|
          p.expects(:sync).once
        end
        @provider.sync
      end
    end

    describe "Provider in invalid state should not pass validation" do
      before(:each) { @provider = Provider.new }

      it "should be invalid without repository type" do
        @provider.name = "some name"
        @provider.repository_url = "https://some.url.here"

        @provider.wont_be :valid?
        @provider.errors[:provider_type].wont_be_empty
      end

      it "should be invalid without name" do
        @provider.repository_url = "https://some.url.here"
        @provider.provider_type = Provider::REDHAT

        @provider.wont_be :valid?
        @provider.errors[:name].wont_be_empty
      end

      it "should be invalid to create two providers with the same name" do
        @provider.name = "some name"
        @provider.repository_url = "http://some.url.here"
        @provider.provider_type = Provider::REDHAT
        @provider.save!

        @provider2 = Provider.new
        @provider2.name = "some name"
        @provider2.repository_url = "http://some.url.here"
        @provider2.provider_type = Provider::REDHAT

        @provider2.wont_be :valid?
        @provider2.errors[:name].wont_be_empty
      end

      describe "Red Hat provider" do
        subject { Provider.create(to_create_rh) }

        it "should allow updating url" do
          subject.repository_url = "http://another.example.com"
          subject.must_be :valid?
        end

        it "should not allow updating name" do
          subject.name = "another name"
          subject.wont_be :valid?
        end
      end
    end

    describe "Provider in valid state" do
      it "should be valid for RH provider" do
        @provider = Provider.create(to_create_rh)
        @provider.must_be :valid?
        @provider.errors[:repository_url].must_be_empty
      end

      it "should be valid for Custom provider" do
        @provider = Provider.create(to_create_custom)
        @provider.must_be :valid?
        @provider.errors[:repository_url].must_be_empty
      end
    end

    describe "Delete a provider" do
      it "should not delete the RH provider" do
        @provider = Provider.create(to_create_rh)
        @provider.destroy
        @provider.destroyed?.must_equal(false)
      end

      it "should delete the Custom provider" do
        @provider = Provider.create(to_create_custom)
        id = @provider.id
        @provider.destroy
        lambda { Provider.find(id) }.must_raise(ActiveRecord::RecordNotFound)
      end
    end

    describe "RH provider URL validation" do
      before(:each) do
        @provider = Provider.new
        @provider.name = "url test"
        @provider.provider_type = Provider::REDHAT
        @default_url = "http://boo.com"
        SETTINGS[:katello].stubs(:redhat_repository_url).returns(@default_url)
      end

      describe "should accept" do
        it "'https://cdn.redhat.com'" do
          @provider.repository_url = "https://cdn.redhat.com"
          @provider.must_be :valid?
        end

        it "'https://cdn.redhat.com/'" do
          @provider.repository_url = "https://cdn.redhat.com/"
          @provider.must_be :valid?
        end

        it "'http://normallength.url/with/sub/directory/'" do
          @provider.repository_url = "http://normallength.url/with/sub/directory/"
          @provider.must_be :valid?
        end

        it "'http://ltl.url/'" do
          @provider.repository_url = "http://ltl.url/"
          @provider.must_be :valid?
        end

        it "'http://reallyreallyreallyreallyreallyextremelylongurl.com/with/lots/of/sub/directories/'" do
          @provider.repository_url = "http://reallyreallyreallyreallyreallyextremelylongurl.com/with/lots/of/sub/directories/over/kill/"
          @provider.must_be :valid?
        end

        it "'http://repo.fedoraproject.org'" do
          @provider.repository_url = "http://repo.fedoraproject.org"
          @provider.must_be :valid?
        end

        it "'http://lzap.fedorapeople.org/fakerepos/fewupdates/'" do
          @provider.repository_url = "http://lzap.fedorapeople.org/fakerepos/fewupdates/"
          @provider.must_be :valid?
        end

        it "'http://dr.pepper.yum:123/nutrition/facts/'" do
          @provider.repository_url = "http://dr.pepper.yum:123/nutrition/facts/"
          @provider.must_be :valid?
        end

        it "'http://something'" do
          @provider.repository_url = "http://something"
          @provider.must_be :valid?
        end
      end

      describe "should refuse" do
        it "blank url" do
          @provider.must_be :valid?
          @provider.repository_url = @default_url
        end

        it "'notavalidurl'" do
          @provider.repository_url = "notavalidurl"
          @provider.wont_be :valid?
        end

        it "'https://'" do
          @provider.repository_url = "https://"
          @provider.wont_be :valid?
        end

        it "'https://dr.pepper.yum:123/nutrition/facts/'" do
          @provider.repository_url = "https://dr.pepper.yum:123/nutrition/facts/"
          @provider.must_be :valid?
        end

        it "'repo.fedorahosted.org/reposity'" do
          @provider.repository_url = "repo.fedorahosted.org/reposity"
          @provider.wont_be :valid?
        end
      end
    end

    describe "URL with Trailing Space" do
      it "should be trimmed (ruby strip)" do
        @provider = Provider.new
        @provider.name = "some name"
        @provider.repository_url = "http://thisurlhasatrailingspacethatshould.com/be/trimmed/   "
        @provider.provider_type = Provider::REDHAT
        @provider.save!
        @provider.repository_url.must_equal("http://thisurlhasatrailingspacethatshould.com/be/trimmed/")
      end
    end

    describe "Custom provider URL validation" do
      before(:each) do
        @provider = Provider.new
        @provider.name = "url test"
        @provider.provider_type = Provider::CUSTOM
      end

      it "shouldn't care about invalid url" do
        @provider.repository_url = "notavalidurl"
        @provider.must_be :valid?
      end
    end

    it 'should be destroyable' do
      disable_product_orchestration
      provider = create(:katello_provider, organization: @organization)
      create(:katello_product, :fedora, provider: provider, organization: @organization)
      assert_raise ActiveRecord::DeleteRestrictionError do
        provider.destroy
      end
    end
  end
end
