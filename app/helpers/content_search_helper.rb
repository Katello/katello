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

module ContentSearchHelper

  def content_types
    content_types = [
      [ _("Products"), "products"],
      [ _("Repositories"), "repos"],
      [ _("Packages"), "packages"],
      [ _("Errata"), "errata"],
      [ _("Content Views"), "views"]
    ]
  end

  def errata_display errata
      types =  {'bugfix'=>'bug_icon-black', 'enhancement'=>'plus_icon-black', 'security'=>'shield_icon-black'}
      icon_class = types[errata[:type]] ||  'enhancement_icon'
      url = short_details_erratum_path(errata.id)
      return "<i class=\"errata-icon #{icon_class}\"  />" + "<span class=\"tipsify-errata\" data-url=\"#{url}\">#{errata.errata_id}</span>"
  end

  def package_display package
    name = package.send(:name)
    ver_rel_arch = package.send(:nvrea).sub(package.send(:name) + '-', '')
    return '<span class="one-line-ellipsis tipsify" title="' + name + '">' + name + '</span><span class="one-line-ellipsis">' + ver_rel_arch + '</span>';
  end

  def repo_compare_name_display repo
    to_ret = {:custom => "<span title=\"#{repo.name}\" class=\"one-line-ellipsis tipsify\">#{repo.name}</span><span class=\"one-line-ellipsis\">#{repo.environment.name}</span>" }

    return to_ret
  end

end
