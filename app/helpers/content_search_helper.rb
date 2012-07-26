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
      types =  {'bugfix'=>'bugzilla_icon', 'enhancement'=>'enhancement_icon', 'security'=>'security_icon'}
      icon_class = types[errata[:type]] ||  'enhancement_icon'
      url = short_details_erratum_path(errata.id)
      return "<i class=\"errata-icon #{icon_class}\"  />" + "<span class=\"tipsify-errata\" data-url=\"#{url}\">#{errata.id}</span>"
  end

end
