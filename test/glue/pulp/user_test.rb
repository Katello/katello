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
  class GluePulpUserTest < ActiveSupport::TestCase
    def self.before_suite
      super
      services  = ['Candlepin', 'ElasticSearch', 'Foreman']
      models    = ['User']
      disable_glue_layers(services, models)
      configure_runcible
    end

    def setup
      @user = build(:katello_user, :batman)
    end

    def test_prune_pulp_only_attributes
      attributes = @user.attributes.merge(:backend_attribute_only => "This is a backend only attribute")
      attributes = @user.prune_pulp_only_attributes(attributes)

      refute_includes attributes, :backend_attribute_only
    end
  end
end
