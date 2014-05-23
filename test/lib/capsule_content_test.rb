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
class CapsuleContentTest < ActiveSupport::TestCase

  include Support::CapsuleSupport

  let(:organization) { taxonomies(:empty_organization) }
  let(:environment) { katello_environments(:organization1_library) }

  specify "listing available environments to add" do
    capsule_content.available_lifecycle_environments(organization.id).wont_include(environment)

    capsule_content.add_lifecycle_environment(environment)
    capsule_content.available_lifecycle_environments.wont_include(environment)
  end

  specify "listing environments in the capsule" do
    capsule_content.add_lifecycle_environment(environment)
    capsule_content.lifecycle_environments.must_include(environment)
    capsule_content.lifecycle_environments(organization.id).wont_include(environment)
  end

end
end
