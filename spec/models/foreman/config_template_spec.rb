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

describe Foreman::ConfigTemplate do
  before do
    Foreman::ConfigTemplate.current_user_getter = lambda { mock('user', :username => 'username') }
  end

  describe '.revision' do
    it 'calls revision on resource', :katello => true do #TODO headpin
      Foreman::ConfigTemplate.resource.
          should_receive(:revision).
          with({ :version => 'version' }, Foreman::ConfigTemplate.header).
          and_return [:data, :response]
      Foreman::ConfigTemplate.revision('version').should == :data
    end
  end

  describe '.build_pxe_default' do
    it 'calls build_pxe_default on resource', :katello => true do #TODO headpin
      Foreman::ConfigTemplate.resource.
          should_receive(:build_pxe_default).
          with(any_args).
          and_return [:data, :response]
      Foreman::ConfigTemplate.build_pxe_default.should == :data
    end
  end

end
