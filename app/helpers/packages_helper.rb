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

module PackagesHelper

  def format_changelog_changes(changes)
    (h(changes).gsub(/\n/, "<br>")).html_safe
  end

  def format_changelog_date(date)
    format_time(DateTime.strptime(date.to_s, "%s").to_date, format: :long)
  end

  def changelog_changes(changes)
    if (lines = changes.split(/\n/)).length > 10
      previewed_changelog(lines)
    else
      format_changelog_changes(changes)
    end
  end

  def previewed_changelog(lines)
    html = format_changelog_changes(lines[0, 10].join("\n"))
    html += content_tag "p" do
      more_lines = number_with_delimiter(lines.length - 10)
      link_to((_("Show %s more line(s)") % more_lines), "", class: "show-more-changelog")
    end
    html += content_tag "div", :class => "more-changelog" do
      format_changelog_changes(lines[10..-1].join("\n"))
    end
  end
end
