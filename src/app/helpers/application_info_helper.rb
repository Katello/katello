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

end
