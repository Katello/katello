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

# Representation of Foreman remote resource.
class Resources::ForemanModel < Resources::AbstractModel

  def self.resource
    super or Resources::Foreman.const_get to_s.demodulize
  rescue NameError => e
    if e.message =~ /Resources::Foreman::#{to_s.demodulize}/
      raise "could not find Resources::Foreman::#{to_s.demodulize}, try to set the resource with #{to_s}.set_resource"
    else
      raise e
    end
  end

  def self.header
    raise 'current user is not set' unless (user = get_current_user)
    super.merge :foreman_user => user.username
  end

  protected

  def parse_errors(hash)
    return hash[resource_name]['errors'] if hash.key? resource_name
    return {hash['error']['parameter_name'] => hash['error']['message']} if hash.key? 'error'
    return hash
  end

  def self.parse_attributes(data)
    data[resource_name] or
        raise ResponseParsingError, data
  end

end



