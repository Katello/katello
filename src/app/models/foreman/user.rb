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

module Foreman
  class User < Resources::ForemanModel

    attributes :login, :mail, :admin, :password

    def json_default_options
      { :only => [:login, :mail, :admin] }
    end

    def json_create_options
      { :only    => [:login, :mail, :admin, :password],
        :methods => [:auth_source_id] }
    end

    def json_update_options
      { :only    => [:mail, :password] }
    end

    def auth_source_id
      1
    end

  end
end
