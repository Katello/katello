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

include OrchestrationHelper
include ProductHelperMethods

describe Repository do

  describe "create repo"  do
    before do
      disable_org_orchestration
      suffix = rand(10**8).to_s
      @organization = Organization.create!(:name => "test_organization#{suffix}", :cp_key => "test_organization#{suffix}")
      @product = new_test_product @organization, @organization.locker
      @ep = EnvironmentProduct.find_or_create(@organization.locker, @product)
    end
    context "product has a gpg" do
      before do
        @gpg = GpgKey.create!(:name => "foo", :organization => @organization, :content=>"100")
        @product.gpg_key = @gpg
        @product.save!
      end
      subject{Repository.create!(:environment_product => @ep, :pulp_id => "pulp-id-#{rand 10**6}",
                                 :name=>"newname#{rand 10**6}", :url => "http://fedorahosted org")}
      it{should_not be_nil}
      its(:gpg_key){should == @product.gpg_key}
    end
  end
end
