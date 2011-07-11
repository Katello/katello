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

module OrchestrationHelper

  def disable_product_orchestration
    Candlepin::Product.stub!(:get).and_return([{:productContent => []}])
    Candlepin::Product.stub!(:add_content).and_return(true)
    Candlepin::Product.stub!(:create).and_return({:id => 1})
    Candlepin::Product.stub!(:create_unlimited_subscription).and_return(true)

    Candlepin::Content.stub!(:create).and_return(true)

    # pulp orchestration
    Candlepin::Product.stub!(:certificate).and_return("")
    Candlepin::Product.stub!(:key).and_return("")
    Pulp::Repository.stub!(:create).and_return([])
  end

  def disable_org_orchestration
    Candlepin::Owner.stub!(:create).and_return({})
    Candlepin::Owner.stub!(:create_user).and_return(true)
    Candlepin::Owner.stub!(:destroy)
  end

end