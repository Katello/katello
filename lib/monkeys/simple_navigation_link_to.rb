module SimpleNavigationLinkTo
  # Rails 3.2.17 makd link_to method protected. Since Katello is transfering
  # to the Foreman navigation, SimpleNavigation should be deprecated and
  # this code should be removed once the SimpleNavigation is removed
  def link_to(name, url, options={})
    template.send(:link_to, html_safe(name), url, options) if template
  end
end

SimpleNavigation::Adapters::Rails.send(:include, SimpleNavigationLinkTo)
