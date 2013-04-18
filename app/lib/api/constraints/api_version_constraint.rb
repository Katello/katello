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

class ApiVersionConstraint
  def initialize(options)
    @version = options[:version]
    @default = options.has_key?(:default) ? options[:default] : false
  end

  def matches?(req)
    req.accept =~ /version=([\d\.]+)/
    if (version = $1) # version is specified in header
      version == @version.to_s # are the versions same
    else
      @default # version is not specified, match if it's default version of api
    end
  end
end
