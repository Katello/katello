require 'katello_test_helper'

module Katello
  describe Provider do
    let(:to_create_rh) do
      {
        :name => "some name",
        :description => "a description",
        :provider_type => Provider::REDHAT,
        :organization => @organization
      }
    end

    let(:to_create_custom) do
      {
        :name => "some name",
        :description => "a description",
        :provider_type => Provider::CUSTOM,
        :organization => @organization
      }
    end

    before(:each) do
      @organization = get_organization(:organization2)
      @organization.redhat_provider.delete
    end

    describe "import_product_from_cp creates product with correct attributes" do
      before(:each) do
        Resources::Candlepin::Product.stubs(:create).returns(:id => "product_id")
        @provider = Provider.new(
                                   :name => 'test_provider',
                                   :provider_type => Provider::REDHAT,
                                   :organization => @organization
        )
        @provider.save!

        @product = Product.create!(:cp_id => "product_id", :label => "prod", :name => "prod", :provider => @provider, :organization => @organization)
      end

      specify { value(@product).wont_be_nil }
      specify { value(@product.provider).must_equal(@provider) }
    end

    describe "sync provider" do
      before(:each) do
        @provider = Provider.create(to_create_custom) do |p|
          p.organization = @organization
        end

        @product1 = Product.create!(:cp_id => "product1_id", :label => "prod1", :name => "product1", :provider => @provider, :organization => @organization)
        @product2 = Product.create!(:cp_id => "product2_id", :label => "prod2", :name => "product2", :provider => @provider, :organization => @organization)
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

        value(@provider).wont_be :valid?
        value(@provider.errors[:provider_type]).wont_be_empty
      end

      it "should be invalid without name" do
        @provider.provider_type = Provider::REDHAT

        value(@provider).wont_be :valid?
        value(@provider.errors[:name]).wont_be_empty
      end

      it "should be invalid to create two providers with the same name" do
        @provider.name = "some name"
        @provider.provider_type = Provider::REDHAT
        @provider.save!

        @provider2 = Provider.new
        @provider2.name = "some name"
        @provider2.provider_type = Provider::REDHAT

        value(@provider2).wont_be :valid?
        value(@provider2.errors[:name]).wont_be_empty
      end

      describe "Red Hat provider" do
        subject { Provider.create(to_create_rh) }

        it "should not allow updating name" do
          subject.name = "another name"
          value(subject).wont_be :valid?
        end
      end
    end

    describe "Provider in valid state" do
      it "should be valid for RH provider" do
        @provider = Provider.create(to_create_rh)
        value(@provider).must_be :valid?
      end

      it "should be valid for Custom provider" do
        @provider = Provider.create(to_create_custom)
        value(@provider).must_be :valid?
      end
    end

    describe "Delete a provider" do
      it "should not delete the RH provider" do
        @provider = Provider.create(to_create_rh)
        @provider.destroy
        value(@provider.destroyed?).must_equal(false)
      end

      it "should delete the Custom provider" do
        @provider = Provider.create(to_create_custom)
        id = @provider.id
        @provider.destroy
        lambda { Provider.find(id) }.must_raise(ActiveRecord::RecordNotFound)
      end
    end

    it 'should be destroyable' do
      provider = create(:katello_provider, organization: @organization)
      create(:katello_product, :fedora, provider: provider, organization: @organization)
      assert_raise ActiveRecord::DeleteRestrictionError do
        provider.destroy
      end
    end
  end
end
