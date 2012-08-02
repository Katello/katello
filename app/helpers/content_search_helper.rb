module ContentSearchHelper

  def content_types
    content_types = [
      [ _("Products"), "products"],
      [ _("Repos"), "repos"],
      [ _("Packages"), "packages"],
      [ _("Errata"), "errata"]
    ]
  end

  def errata_display errata
      types =  {'bugfix'=>'bug_icon_black', 'enhancement'=>'plus_icon_black', 'security'=>'shield_icon_black'}
      icon_class = types[errata[:type]] ||  'enhancement_icon'
      url = short_details_erratum_path(errata.id)
      return "<i class=\"errata-icon #{icon_class}\"  />" + "<span class=\"tipsify-errata\" data-url=\"#{url}\">#{errata.id}</span>"
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
