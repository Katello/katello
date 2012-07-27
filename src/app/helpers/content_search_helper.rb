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

end
