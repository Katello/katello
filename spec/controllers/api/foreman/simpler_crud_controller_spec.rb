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

describe Api::Foreman::SimpleCrudController do
  include LoginHelperMethods
  before { login_user_api }

  let(:foreman_model_1) { mock 'foreman_model_1' }
  let(:foreman_model_2) { mock 'foreman_model_2' }
  let(:foreman_model) { foreman_model_1 }

  describe '#foreman_model' do
    context 'when nothing is set' do
      it { lambda { controller.foreman_model }.should raise_error }
    end

    context 'when set to foreman_model_1 on class' do
      before { controller.class.send :foreman_model=, foreman_model_1 }
      it 'returns the foreman_model_1 ' do
        controller.foreman_model.should == foreman_model_1
      end
      after { controller.class.send :foreman_model=, nil }

      context 'when set to foreman_model_2 on instance' do
        before { controller.foreman_model = foreman_model_2 }
        it 'returns foreman_model_2' do
          controller.foreman_model.should == foreman_model_2
        end
      end
    end
  end
end
