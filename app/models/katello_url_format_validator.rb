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

class KatelloUrlFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    
    # build protocol regex
    # default: allow "http" only
    p = options[:protocol]
    if p.nil?
      protocol = "(http)"
    elsif p.size == 1
      protocol = "(#{p.first})"
    else
      protocol = "("
      for i in p do
        protocol += i
        protocol += "|" unless i == p.last
      end
      protocol += ")"
    end
    
    # allow port numbers?
    #
    # true: require port numbers
    # false: disallow port numbers
    # (default) nil: port numbers allowed, but not required
    o = options[:port_numbers]
    if o.nil?
      port_number = "(:[0-9]{1,5})?"
    elsif o
      port_number = ":[0-9]{1,5}"
    else
      port_number = ""
    end
    
    if value
      record.errors[attribute] << N_("is invalid") unless value =~ /^#{protocol}:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}#{port_number}(\/.*)?$/ix
    else
      record.errors[attribute] << N_("can't be blank")
    end
  end
  
end