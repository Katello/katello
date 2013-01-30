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



module Authorization::ActivationKey
  def self.included(base)
    base.class_eval do


      def self.readable(org)
        ActivationKey.readable?(org) ? where(:organization_id=>org.id) : where("0 = 1")
      end

      # returns list of virtual permission tags for the current user
      def self.list_tags(organization_id)
        [] #don't list tags for keys
      end

      def self.list_verbs(global = false)
        {
          :read_all => _("Read Activation Keys"),
          :manage_all => _("Administer Activation Keys")
        }.with_indifferent_access
      end

      def self.read_verbs
        [:read_all]
      end

      def self.no_tag_verbs
        ::ActivationKey.list_verbs.keys
      end

      def self.readable?(org)
        User.allowed_to?([:read_all, :manage_all], :activation_keys, nil, org)
      end

      def self.manageable?(org)
        User.allowed_to?([:manage_all], :activation_keys, nil, org)
      end

    end
  end
end
