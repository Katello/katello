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

require 'test_helper'

class DistributorTest < ActiveSupport::TestCase
  fixtures :all

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "Distributor"]
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models, true)
  end

  def self.after_suite
    Distributor.delete_all
  end

  def setup
    @distributor = Distributor.find(distributors(:acme_distributor))
  end

  def test_create
    new_distributor = @distributor.dup
    refute new_distributor.save
    new_distributor.name = "ACME Distributor2"
    assert new_distributor.valid?
  end

  def test_update
    assert @distributor.save!
  end

end
