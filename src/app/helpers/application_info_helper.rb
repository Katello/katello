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

module ApplicationInfoHelper

  def component_status_icon(status)
    if status == "fail"
      content_tag :span, "", :class => "error_icon"
    elsif status == "ok"
      content_tag :span, "", :class => "check_icon"
    else
      ""
    end
  end

  def redhat_bugzilla_link
    url = "https://bugzilla.redhat.com/enter_bug.cgi?product=CloudForms%20System%20Engine"
    link_to (_("the %s Bugzilla") % AppConfig.app_name), url
  end

  def doc_link
    url = "https://access.redhat.com/knowledge/docs/CloudForms/"
    link_to _("the CloudForms Documentation"), url
  end

  def can_read_system_info?
    current_user.present? && Organization.any_readable?
  end
end
