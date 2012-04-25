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

describe PackagesController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper


    before (:each) do
      set_default_locale
      login_user

    end

    describe "get auto_complete_package" do
      before (:each) do
        Glue::Pulp::Package.should_receive(:name_search).once.and_return(["a", "aa"])
      end

      it 'should succeed' do
        get :auto_complete_library, :term => "a"
        response.should be_success
      end
    end

    describe "get validate name library" do 
      before (:each) do
        Glue::Pulp::Package.should_receive(:search).once.and_return([{}])
      end

      it 'should succeed' do
        get :validate_name_library, :term => "a"
        response.should be_success
      end
  
    end

end 
