require 'katello_test_helper'

module Katello
  describe ContentCredential do
    include OrchestrationHelper
    include OrganizationHelperMethods

    let(:organization) do
      disable_org_orchestration
    end

    describe "create gpg key" do
      before(:each) do
        @organization = get_organization
        @test_gpg_content = File.read("#{Katello::Engine.root}/spec/assets/gpg_test_key")
      end

      it "should be successful with valid parameters" do
        content_credential = ContentCredential.new(:name => "Gpg Key 1", :content => @test_gpg_content, :organization => @organization)
        assert content_credential.valid?
      end

      it 'should be destroyable when not attached to a product or root repository' do
        content_credential = ContentCredential.create!(:name => "Gpg Key 1", :content => @test_gpg_content, :organization => @organization)
        assert_not_equal content_credential.destroy, false
      end

      it 'should not be destroyable when attached to a product' do
        content_credential = ContentCredential.create!(:name => "Gpg Key 1", :content => @test_gpg_content, :organization => @organization)
        product = katello_products(:empty_product)
        product.gpg_key = content_credential
        product.save!
        assert_raises(ActiveRecord::InvalidForeignKey) { content_credential.destroy }
        product.destroy
        assert_nothing_raised { content_credential.destroy }
      end

      it 'should not be destroyable when attached to a root repository' do
        content_credential = ContentCredential.create!(:name => "Gpg Key 1", :content => @test_gpg_content, :organization => @organization)
        product = katello_products(:empty_product)
        repo = build(:katello_root_repository,
                      :product => product,
                      :name => 'pizza',
                      :label => 'another_label')
        repo.gpg_key = content_credential
        repo.save!
        assert_raises(ActiveRecord::DeleteRestrictionError) { content_credential.destroy }
        repo.destroy
        assert_nothing_raised { content_credential.destroy }
      end

      it "should be unsuccessful without content" do
        content_credential = ContentCredential.new(:name => "Gpg Key 1", :organization => @organization)
        refute content_credential.valid?
      end

      it "should be unsuccessful without a name" do
        content_credential = ContentCredential.new(:content => @test_gpg_content, :organization => @organization)
        refute content_credential.valid?
      end

      it "should be unsuccessful without proper gpg key" do
        content_credential = ContentCredential.new(:name => "Gpg Key 1", :content => "foo-bar-baz", :organization => @organization)
        if SETTINGS[:katello][:gpg_strict_validation]
          refute content_credential.valid?
        else
          assert content_credential.valid?
        end
      end

      it "should be unsuccessful with binary content" do
        content = "\x81\xA4user\x83\xA3age\x18\xA4name\xA4ivan\xA5float\xCB@\x93J=p\xA3\xD7\n"
        content.force_encoding(::Encoding::ASCII_8BIT)
        content_credential = ContentCredential.new(:name => "Gpg Key 1", :content => content, :organization => @organization)
        refute content_credential.valid?
      end
    end
  end
end
