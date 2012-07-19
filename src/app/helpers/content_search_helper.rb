module ContentSearchHelper

  def content_types
    content_types = [
      [ _("Products"), "products"],
      [ _("Repos"), "repos"],
      [ _("Packages"), "packages"],
      [ _("Errata"), "errata"]
    ]
  end

  end
