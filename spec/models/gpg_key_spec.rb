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

require 'katello_test_helper'

module Katello
  describe GpgKey, :katello => true do
    include OrchestrationHelper
    include OrganizationHelperMethods
    include AuthorizationHelperMethods

    let(:organization) do
      disable_org_orchestration
      Organization.create!(:name => "Duh", :label => "ahaha")
    end

    describe "permission checks" do

      let(:gpg) {GpgKey.create!(:name => "Gpg key", :organization => organization, :content => File.open("#{Katello::Engine.root}/spec/assets/gpg_test_key").read )}

      describe "check on read operations" do
        [[:gpg, :organizations],[:read, :organizations],[:read, :providers]].each do |(perm, resource)|
          it "user with #{perm} on #{resource} should be allowed to work with gpg" do
          User.current = user_with_permissions{|u| u.can(perm, resource,nil, organization, :all_tags => true)}
          GpgKey.find(gpg.id).must_be :readable?
          GpgKey.readable(organization).wont_be :empty?
          GpgKey.readable(organization).must_equal([gpg])
        end
        end
        it "user without perms should not  be allowed to work with gpg" do
          User.current = user_without_permissions
          GpgKey.find(gpg.id).wont_be :readable?
          GpgKey.readable(organization).must_be :empty?
        end
      end

      describe "check on write operations" do
        it "user with #{:gpg} on #{:org} should be allowed to work with gpg" do
          User.current = user_with_permissions{|u| u.can(:gpg, :organizations,nil, organization, :all_tags => true)}
          GpgKey.find(gpg.id).must_be :manageable?
          GpgKey.manageable(organization).must_equal([gpg])
        end

        it "user without perms should not  be allowed to work with gpg" do
          User.current = user_without_permissions
          GpgKey.find(gpg.id).wont_be :manageable?
          GpgKey.manageable(organization).must_be :empty?
        end
      end

    end

    describe "create gpg key" do
      before(:each) do
        new_test_org_model
        @test_gpg_content = File.open("#{Katello::Engine.root}/spec/assets/gpg_test_key").read
      end

      it "should be successful with valid parameters" do
        gpg_key = GpgKey.new(:name => "Gpg Key 1", :content => @test_gpg_content, :organization => @organization)
        gpg_key.must_be :valid?
      end

      it 'should be destroyable' do
        gpg_key = GpgKey.create!(:name => "Gpg Key 1", :content => @test_gpg_content, :organization => @organization)
        disable_product_orchestration
        create(:product, :fedora, provider: create(:provider, organization: organization)).tap do |product|
          product.gpg_key = gpg_key
          product.save!
        end
        gpg_key.destroy.wont_equal(false)
      end

      it "should be unsuccessful without content" do
        gpg_key = GpgKey.new(:name => "Gpg Key 1", :organization => @organization)
        gpg_key.wont_be :valid?
      end

      it "should be unsuccessful without a name" do
        gpg_key = GpgKey.new(:content => @test_gpg_content, :organization => @organization)
        gpg_key.wont_be :valid?
      end

      it "should be unsuccessful without proper gpg key" do

        gpg_key = GpgKey.new(:name => "Gpg Key 1", :content => "foo-bar-baz", :organization => @organization)
        if Katello.config.gpg_strict_validation
          gpg_key.wont_be :valid?
        else
          gpg_key.must_be :valid?
        end
      end

      it "should be unsuccessful with binary content" do
        content = "\x81\xA4user\x83\xA3age\x18\xA4name\xA4ivan\xA5float\xCB@\x93J=p\xA3\xD7\n"
        content.force_encoding(::Encoding::ASCII_8BIT)
        gpg_key = GpgKey.new(:name => "Gpg Key 1", :content => content, :organization => @organization)
        gpg_key.wont_be :valid?
      end

      it "should be unsuccessful with a key longer than #{GpgKey::MAX_CONTENT_LENGTH} characters" do
        gpg_key = GpgKey.new(:name => "Gpg Key 8", :content => ("abc123" * GpgKey::MAX_CONTENT_LENGTH), :organization => @organization)
        gpg_key.wont_be :valid?
      end
    end

  end
end
