module Katello
  module UsersHelper
    def organization_select(org_id = nil, optional = true, no_org_choice = nil)
      if current_user.id == @user.id
        orgs = current_user.allowed_organizations.reject do |org|
          !org.any_systems_registerable?
        end
      else
        orgs = Organization.all
      end
      choices = orgs.map { |a| [a.name, a.id] }
      if optional
        selected = org_id
        prompt = nil
        no_org_choice ||= _('Select Organization')
        choices.unshift [no_org_choice, nil]
      else
        selected = org_id || current_organization.id
        prompt = _('Select Organization')
      end
      select(:org_id, "org_id", choices, {:prompt => prompt, :id => "org_field", :selected => selected}, :class => "one-line-ellipsis", :style => "width: 300px; max-width: 300px")
    end

    def locale_select(locale = nil)
      choices = [_('Use Browser Locale')]
      selected = locale.nil? ? _('Use Browser Locale') : locale
      select(:locale, "locale", choices,
             :prompt => nil, :id => "locale_field",
             :selected => selected)
    end
  end
end
