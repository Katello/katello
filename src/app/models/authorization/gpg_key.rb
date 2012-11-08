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



module Authorization::GpgKey

  def self.included(base)
    base.class_eval do

      def self.readable(org)
         if org.readable? || org.gpg_keys_manageable? || ::Provider.any_readable?(org)
            where(:organization_id => org.id)
         else
           where("0 = 1")
         end
      end

      def self.manageable(org)
         if org.gpg_keys_manageable?
            where(:organization_id => org.id)
         else
           where("0 = 1")
         end
      end

      def self.createable?(organization)
        organization.gpg_keys_manageable?
      end

      def self.any_readable?(organization)
        organization.readable? || organization.gpg_keys_manageable? || ::Provider.any_readable?(organization)
      end

    end
  end


  def readable?
     GpgKey.any_readable?(organization)
  end

  def manageable?
     organization.gpg_keys_manageable?
  end

end
