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

module ErrataHelper
  def errata_title errata
    # Provide the errata title in the format of Advisory: Title. (E.g. "RHSA_2011:1230 : Package X security update").
    # Remove from the title the severity, if included.
    title = errata.errata_id  # the id contains the advisory
    title += " : " + errata.title.sub(/Critical: |Important: |Moderate: |Low: /, "")
  end

  def errata_human_type(type)
    case type
      when  Errata::SECURITY
        _('Security')
      when  Errata::ENHANCEMENT
        _('Enhancement')
      when  Errata::BUGZILLA
        _('Bug Fix')
    end
  end
end
