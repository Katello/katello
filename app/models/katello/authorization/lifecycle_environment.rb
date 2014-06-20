#
# Copyright 2014 Red Hat, Inc.
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
module Authorization::LifecycleEnvironment
  extend ActiveSupport::Concern

  DISTRIBUTORS_READABLE = [:read_distributors, :register_distributors, :update_distributors, :delete_distributors]

  include Authorizable
  include Katello::Authorization

  def readable?
    authorized?(:view_lifecycle_environments)
  end

  def creatable?
    self.class.creatable?
  end

  def editable?
    authorized?(:edit_lifecycle_environments)
  end

  def deletable?
    authorized?(:destroy_lifecycle_environments)
  end

  def promotable_or_removable?
    authorized?(:promote_or_remove_content_views_to_environments)
  end

  def distributors_readable?
    self.organization.distributors_readable? ||
        (Katello.config.katello? &&
            ::User.allowed_to?(DISTRIBUTORS_READABLE, :environments, self.id, self.organization))
  end

  def distributors_editable?
    ::User.allowed_to?([:update_distributors], :organizations, nil, self.organization) ||
        (Katello.config.katello? &&
            ::User.allowed_to?([:update_distributors], :environments, self.id, self.organization))
  end

  def distributors_deletable?
    ::User.allowed_to?([:delete_distributors], :organizations, nil, self.organization) ||
        (Katello.config.katello? &&
            ::User.allowed_to?([:delete_distributors], :environments, self.id, self.organization))
  end

  def distributors_registerable?
    self.organization.distributors_registerable? ||
        (Katello.config.katello? &&
            ::User.allowed_to?([:register_distributors], :environments, self.id, self.organization))
  end

  module ClassMethods

    def readable
      authorized(:view_lifecycle_environments)
    end

    def promotable
      authorized(:promote_or_remove_content_views_to_environments)
    end

    def promotable?
      User.current.can?(:promote_or_remove_content_views_to_environments)
    end

    def any_promotable?
      promotable.count > 0
    end

    def creatable?
      ::User.current.can?(:create_lifecycle_environments)
    end

    def content_readable(org)
      readable.where(:organization_id => org)
    end

    def distributors_readable(org)
      if  org.distributors_readable?
        where(:organization_id => org)
      else
        authorized_items(org, DISTRIBUTORS_READABLE)
      end
    end

    def distributors_registerable(org)
      if org.distributors_registerable?
        where(:organization_id => org)
      else
        authorized_items(org, [:register_distributors])
      end
    end
  end

end
end
