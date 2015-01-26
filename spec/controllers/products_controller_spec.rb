# encoding: UTF-8

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
  describe ProductsController do
    include LocaleHelperMethods
    include OrganizationHelperMethods

    describe "(katello)" do
      before do
        setup_controller_defaults
        @organization = get_organization
      end

      describe "get auto_complete_product" do
        before :each do
          Product.expects(:search).once.returns([OpenStruct.new(:name => "a", :id => 100)])
        end

        it 'should succeed' do
          get :auto_complete, :term => "a"
          must_respond_with(:success)
        end
      end
    end
  end
end
