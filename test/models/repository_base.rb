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

require 'katello_test_helper'

module Katello
  class RepositoryTestBase < ActiveSupport::TestCase

    def self.before_suite
      services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
      models    = ['Repository', 'Package', 'KTEnvironment']
      disable_glue_layers(services, models, true)
    end

    def setup
      @acme_corporation     = get_organization(:organization1)

      @fedora_17_x86_64     = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      @fedora_17_x86_64_dev = Repository.find(katello_repositories(:fedora_17_x86_64_dev).id)
      @fedora               = Product.find(katello_products(:fedora).id)
      @library              = KTEnvironment.find(katello_environments(:library).id)
      @dev                  = KTEnvironment.find(katello_environments(:dev).id)
      @staging              = KTEnvironment.find(katello_environments(:staging).id)
      @unassigned_gpg_key   = GpgKey.find(katello_gpg_keys(:unassigned_gpg_key).id)
      @admin                = User.find(users(:admin))
    end

  end
end
