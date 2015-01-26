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

module Katello
  describe GpgKey, :katello => true do
    include OrchestrationHelper
    include OrganizationHelperMethods

    let(:organization) do
      disable_org_orchestration
      as_admin do
        User.current.stubs(:remote_id).returns(User.current.login)
      end
    end

    describe "create gpg key" do
      before(:each) do
        @organization = get_organization
        @test_gpg_content = File.open("#{Katello::Engine.root}/spec/assets/gpg_test_key").read
      end

      it "should be successful with valid parameters" do
        gpg_key = GpgKey.new(:name => "Gpg Key 1", :content => @test_gpg_content, :organization => @organization)
        gpg_key.must_be :valid?
      end

      it 'should be destroyable' do
        gpg_key = GpgKey.create!(:name => "Gpg Key 1", :content => @test_gpg_content, :organization => @organization)
        disable_product_orchestration
        product = katello_products(:fedora)
        product.gpg_key = gpg_key
        product.save!
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
