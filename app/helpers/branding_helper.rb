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


module BrandingHelper
  def project_name
    Katello.config.app_name
  end

  def default_title
    if Katello.config.katello?
      _("Open Source Systems Management")
    else
      _("Open Source Subscription Management")
    end
  end

  def redhat_bugzilla_link
    url = "https://bugzilla.redhat.com/enter_bug.cgi?product=Katello"
    link_to (_("the %s Bugzilla") % release_name), url
  end

  def release_name
    Katello.config.app_name
  end
end
