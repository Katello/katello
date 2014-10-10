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
  class LabelFromNameTest < ActiveSupport::TestCase

    def self.before_suite
      services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
      models    = ['Repository', 'KTEnvironment', 'ContentView', 'ContentViewVersion',
                   'ContentViewEnvironment', 'Organization', 'Product',
                   'Provider']
      disable_glue_layers(services, models, true)
    end

    def test_create_wtih_empty_label
      org = get_organization
      library = KTEnvironment.find(katello_environments(:library).id)
      env = KTEnvironment.create!(:name => "justin11", :organization => org, :prior => library)
      refute_nil env.label
    end

    def test_update_label
      staging = KTEnvironment.find(katello_environments(:staging).id)
      assert_raises ActiveRecord::RecordInvalid do
        staging.update_attributes!(:label => "crazy")
      end
    end

  end
end
