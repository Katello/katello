#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

# utility functions available during Rails boot time
module Katello
  module BootUtil
    def self.headpin?
      ENV['RAILS_RELATIVE_URL_ROOT'] == '/headpin' || ENV['RAILS_RELATIVE_URL_ROOT'] == '/sam'
    end

    def self.katello?
      not headpin?
    end

    def self.app_root
      root = ENV['RAILS_RELATIVE_URL_ROOT']
      if root != nil && !root.empty?
        return root.split('/')[1]
      else
        return 'katello'
      end
    end
  end
end
