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

  end

end
end
