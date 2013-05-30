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

module ContentSearchHelper

  def content_types
    content_types = [
      [ _("Content Views"), "views"],
      [ _("Products"), "products"],
      [ _("Repositories"), "repos"],
      [ _("Packages"), "packages"],
      [ _("Errata"), "errata"]
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
    url = details_package_path(package.id)
    return "<span class=\"tipsify-package\" data-url=\"#{url}\">#{name}</span><span class='one-line-ellipsis'>#{ver_rel_arch}</span>"
  end

  def repo_compare_name_display repo
    to_ret = {:custom => "<span title=\"#{repo.environment.name}\" class=\"one-line-ellipsis\">#{repo.environment.name}</span>" +
        "<span class=\"one-line-ellipsis tipsify\" title=\"#{repo.content_view.name}\">#{repo.content_view.name}</span>"+
        "<span class=\"one-line-ellipsis tipsify\" title=\"#{repo.name}\">#{repo.name}</span>"}

    return to_ret
  end

  def view_compare_name_display(view, env)
    version = _("version %s") % view.version(env).version
    to_ret = {:custom => <<EOS
<span title=\"#{view.name} #{version}\" class=\"one-line-ellipsis tipsify\">#{view.name}</span><span class=\"one-line-ellipsis\">#{env.name}</span>
EOS
      }

    return to_ret
  end

end
