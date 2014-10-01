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
#
require 'katello_test_helper'

module Katello
  describe ::Actions::Candlepin::ReindexPoolSubscriptionHandler do
    describe 'when notified with entitlement.deleted' do
      let(:mymessage) do
        result = {:subject => "entitlement.deleted" }
        result[:content] = JSON.generate({:referenceId => 123})
        OpenStruct.new(result)
      end

      it 'reindex the pool' do
        pool = rand(1100);
        ::Katello::Pool.stubs(:find_pool).returns(pool)
        ::Katello::Pool.expects(:index_pools).with([pool])

        ::Actions::Candlepin::ReindexPoolSubscriptionHandler.new(Rails.logger).handle(mymessage)
      end
    end
  end
end
