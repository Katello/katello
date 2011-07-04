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
    p = options[:protocol]

    if p.nil?
      pr = "(http)"
    elsif p.size == 1
      pr = "(#{p.first})"
    else
      pr = "("
      for i in p do
        pr += i
        pr += "|" unless i == p.last
      end
      pr += ")"
    end

    if value
      record.errors[attribute] << N_("is invalid") unless value =~ /^#{pr}:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
    else
      record.errors[attribute] << N_("can't be blank")
    end
  end

end