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
  class RepositoryPresenterTest < ActiveSupport::TestCase
    def setup
      @presenter = RepositoryPresenter.new(katello_repositories(:fedora_17_x86_64))
    end

    def test_content_view_environments
      content_view_environments = @presenter.content_view_environments

      assert_equal content_view_environments.length, 2
    end
  end
end
