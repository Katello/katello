#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
module DashboardHelper

  def dashboard_entry(name, partial, dropbutton)
    render :partial => "entry", :locals => {:name => name, :partial => partial, :dropbutton => dropbutton}
  end

  def dashboard_ajax_entry(name, identifier, url, class_wrapper, dropbutton, quantity = 5)
    url = "/katello#{url}" if !url.match("/katello")
    render :partial => "ajax_entry", :locals => {:name => name, :url => url, :class_wrap => class_wrapper, :identifier => identifier, :dropbutton => dropbutton, :quantity => quantity}
  end

  def content_hosts_search_status_link(anchor_text, status)
    href_params = {:status => status}
    href_format = "/content_hosts?search=status:%{status}"
    link_to(anchor_text, href_format % href_params)
  end

  def user_notices(num = quantity, options = {})
    truncate = options[:truncate] || 45

    Notice.for_user(current_user).for_org(current_organization).order("created_at DESC").limit(num).map do |notice|
      { :text => notice.text.truncate(truncate), :level => notice.level, :date => notice.created_at }
    end
  end

  def content_view_histories(num  = quantity)
    content_views = ContentView.where(:organization_id => current_organization.id).readable
    ContentViewHistory.joins(:content_view_version => :content_view).
        where("#{ContentView.table_name}.id" => content_views).
        order("#{Katello::ContentViewHistory.table_name}.updated_at DESC").
        limit(num)
  end

  def content_view_history_view_info(history)
    version = history.content_view_version
    if version.content_view.readable?
      link_to(content_view_version_message(version), "/content_views/#{version.content_view.id}/versions")
    else
      content_view_version_message(version)
    end
  end

  def content_view_history_class(history)
    case history.status
    when ContentViewHistory::IN_PROGRESS
      "gears_icon"
    when ContentViewHistory::FAILED
      "error_icon"
    when ContentViewHistory::SUCCESSFUL
      "check_icon"
    end
  end

  def content_view_history_action(history)
    case history.task.label
    when "Actions::Katello::ContentView::Publish"
      _("Published new version")
    when "Actions::Katello::ContentView::Promote"
      _("Promoted to %{environment}") % { :environment => history.environment.name }
    when "Actions::Katello::ContentView::Remove"
      _("Deleted from %{environment}") % { :environment => history.environment.name }
    end
  end

  def content_view_message(history)
    case history.status
    when ContentViewHistory::IN_PROGRESS
      _("In Progress")
    when ContentViewHistory::FAILED
      _("Failed")
    when ContentViewHistory::SUCCESSFUL
      _("Success")
    end
  end

  def content_view_version_message(version)
    _("%{content_view_name}, version %{content_view_version}") %
        { :content_view_name => version.content_view.name, :content_view_version => version.version }
  end

  def products_synced(num = quantity)
    syncing_products = []
    synced_products = []

    Product.in_org(current_organization).syncable_content.syncable.each do |prod|
      if !prod.sync_status.start_time.nil?
        syncing_products << prod
      else
        synced_products << prod
      end
    end

    syncing_products.sort do |a, b|
      a.sync_status.start_time <=> b.sync_status.start_time
    end

    return (syncing_products + synced_products)[0..num]

  end

  def sync_percentage(product)
    stat = product.sync_status.progress
    return 0 if stat.total_size == 0
    "%.0f" % ((stat.total_size - stat.size_left) * 100 / stat.total_size).to_s
  end

  def subscription_counts
    Glue::Candlepin::OwnerInfo.new(current_organization)
  end

  def errata_type_class(errata)
    case errata.type
    when Errata::SECURITY
      return "security_icon"
    when Errata::ENHANCEMENT
      return "enhancement_icon"
    when Errata::BUGZILLA
      return "bugzilla_icon"
    end
  end

  def errata_product_names(errata, repos)
    # return a comma-separated list of product names that this errata is associated with

    # the list will be determined by evaluating the repoids in the errata against the products
    # associated with the list of repos provided
    products = []
    unless errata[:repoids].blank?
      errata[:repoids].each do |repoid|
        products << (repos.detect { |r| r.pulp_id == repo.id }).product.name
      end
    end
    products.empty? ? "" : products.join(', ')
  end

  def system_path_helper(system)
    "/content_hosts/#list_search=id:#{system.id}&panel=system_#{system.id}&panelpage=errata"
  end

  def get_checkin(system)
    if system.checkin_time
      return  format_time system.checkin_time
    end
    _("Never checked in.")
  end

  def dashboard_layout
    @layout ||= Dashboard::Layout.new(current_organization, current_user)
  end

  def render_dashboard
    output = ""
    dashboard_layout.columns.each do |col|
      output += content_tag "div", class: "col-md-6 column" do
        render_column(col)
      end
    end
    output.html_safe
  end

  def has_dropbutton_quantity(widget_name)
    !(%w(subscriptions_totals subscriptions).include? widget_name)
  end

  def render_column(column)
    output = ""
    column.each do |widget|
      has_dropbutton = has_dropbutton_quantity(widget.name)
      if widget.content_path
        output += dashboard_ajax_entry(widget.title, widget.name, widget.content_path, "widget", has_dropbutton)
      else
        output += dashboard_entry(widget.title, widget.name, has_dropbutton)
      end
    end
    output.html_safe
  end

  def widget_drag_and_drop_text
    _("Click on the widget title text to drag and drop.")
  end

end
end
