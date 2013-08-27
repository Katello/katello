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

module PromotionsHelper
  include ActionView::Helpers::JavaScriptHelper

  include BreadcrumbHelper
  include ChangesetBreadcrumbs
  include ContentBreadcrumbs
  include ErrataHelper

  #returns a proc to generate a url for the env_selector
  def breadcrumb_url_proc
    lambda do |args|
      promotion_path(args[:environment].name,
        :next_env_id => (args[:next_environment].id if args[:next_environment] && args[:environment].library?))
    end
  end

  def show_new_button?(manage_promotion, manage_deletion)
    if @environment.library?
      manage_promotion && @next_environment
    else
      manage_deletion || (manage_promotion && @next_environment)
    end
  end

end

