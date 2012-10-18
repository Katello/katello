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

module Katello
  class DbSetupCheck
    # Ensures sqlite is not used as a database engine. It's not supported
    # by the Katello project.
    def self.check!
      if ActiveRecord::Base.configurations[Rails.env] and
          ActiveRecord::Base.configurations[Rails.env]['adapter'] == 'sqlite3' and
          not ENV['FORCE_DB_SETUP']
        raise 'SQLite3 is not supported. If you still want to use this adapeter, set FORCE_DB_SETUP=true.'
      end
    end
  end
end
