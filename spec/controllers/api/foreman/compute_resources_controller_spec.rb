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

require 'spec_helper'

describe Api::Foreman::ComputeResourcesController do
  if Katello.config.use_foreman
    include LoginHelperMethods

    let(:a_model) { controller.foreman_model.new }

    before do
      login_user_api

      a_model.stub :save! => true
      controller.foreman_model.stub :new_provider => a_model
    end

    it_behaves_like 'simple crud controller'
  else
    pending 'foreman is not enabled, skipping'
  end
end
