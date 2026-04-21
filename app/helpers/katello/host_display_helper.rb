module Katello
  module HostDisplayHelper
    def hosts_change_content_source
      [{ action: [_('Change Content Source'), '/change_host_content_source', false], priority: 100 }]
    end

    def host_status_icon(status)
      colours = [:green, :yellow, :red]

      colour = colours[status] || :red

      icons = {
        green: "#{colour} host-status pficon pficon-ok status-ok",
        yellow: "#{colour} host-status pficon pficon-info status-warn",
        red: "#{colour} host-status pficon pficon-error-circle-o status-error",
      }

      content_tag(:span, '', class: icons[colour])
    end

    def errata_counts(host)
      counts = host.content_facet_attributes&.errata_counts || {}
      render partial: 'katello/hosts/errata_counts', locals: { counts: counts, host: host }
    end

    def host_registered_time(host)
      return ''.html_safe unless host.subscription_facet_attributes&.registered_at

      date_time_relative_value(host.subscription_facet_attributes.registered_at)
    end

    def host_checkin_time(host)
      return ''.html_safe unless host.subscription_facet_attributes&.last_checkin

      date_time_relative_value(host.subscription_facet_attributes.last_checkin)
    end
  end
end
