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

module Katello
  class Api::V2::ApiController < Api::ApiController

    include Api::Version2
    include Api::V2::Rendering
    include Api::V1::ErrorHandling

    # support for session (thread-local) variables must be the last filter in this class
    include Util::ThreadSession::Controller
    include AuthorizationRules

  end
end
