#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'net/ldap'

module Ldap
  def self.valid_ldap_authentication?(uid, password)
    ldap = LdapConnection.new
    ldap.bind? uid, password
  end

  class LdapConnection
    attr_reader :ldap, :host, :base

    def initialize(config={})
      @ldap = Net::LDAP.new
      @ldap.host = @host = AppConfig.ldap.host
      @base = AppConfig.ldap.base
    end

    def bind?(uid=nil, password=nil)
      @ldap.auth "uid=#{uid},#{@base}", password
      @ldap.bind
    end
  end
end
