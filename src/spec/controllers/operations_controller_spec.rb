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

describe OperationsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  describe "rules" do
    describe "GET index - on users" do
      let(:action) {:index}
      let(:req) { get 'index' }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :users,nil, nil) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "GET index - on roles" do
      let(:action) {:index}
      let(:req) { get 'index' }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :roles,nil, nil) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

  end

end
