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
  module Validators
    class PriorValidator < ActiveModel::Validator
      def validate(record)
        #need to ensure that prior
        #environment already does not have a successor
        #this is because in v1.0 we want
        # prior to have only one child (unless its the Library)
        has_no_prior = true
        if record.organization
          has_no_prior = record.organization.environments.reject{|env| env == record || env.prior != record.prior || env.prior == env.organization.library}.empty?
        end
        record.errors[:prior] << _("environment can only have one child") unless has_no_prior

        # only Library can have prior=nil
        record.errors[:prior] << _("environment required") unless !record.prior.nil? || record.library?
      end
    end
  end
end
