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

module Katello
module DashboardHelper

  def dashboard_entry(name, partial, dropbutton)
    render :partial => "entry", :locals => {:name => name, :partial => partial, :dropbutton => dropbutton}
  end

  def dashboard_ajax_entry(name, identifier, url, class_wrapper, dropbutton, quantity = 5)
    url = Katello.config[:url_prefix] + url if !url.match(Katello.config[:url_prefix])
    render :partial => "ajax_entry", :locals => {:name => name, :url => url, :class_wrap => class_wrapper, :identifier => identifier, :dropbutton => dropbutton, :quantity => quantity}
  end

  def systems_search_status_link(anchor_text, status)
    href_params = {:systems_path => katello_systems_path, :status => status}
    href_format = "%{katello_systems_path}#/systems?search=status:%{status}"
    link_to(anchor_text, href_format % href_params)
  end

  def user_notices(num = quantity, options = {})
    truncate = options[:truncate] || 45

    Notice.for_user(current_user).for_org(current_organization).order("created_at DESC").limit(num).map do |notice|
      { :text => notice.text.truncate(truncate), :level => notice.level, :date => notice.created_at }
    end
  end

  def content_view_versions(num = quantity)
    return ContentViewVersion.readable(current_organization).non_default_view.joins(:task_status).
        order("#{Katello::TaskStatus.table_name}.updated_at DESC").limit(num)
  end

  def content_view_name(version)
    if version.content_view.content_view_definition.readable?
      link_to(version.content_view.name, katello_content_view_path_helper(version))
    else
      version.content_view.name
    end
  end

  def content_view_class(version)
    if version.task_status.finished?
      "check_icon"
    elsif version.task_status.pending? && version.task_status.start_time
      "gears_icon"  #running
    else
      "clock_icon" #pending
    end
  end

  def content_view_message(version)
    if version.task_status.error?
      _("Failed")
    elsif version.task_status.finished?
      _("Success")
    else # pending
      if version.task_status.task_type == TaskStatus::TYPES[:content_view_refresh][:type].to_s
        _("Refreshing")
      else
        _("Publishing")
      end
    end
  end

  def content_view_path_helper(version)
    katello_content_view_definitions_path +
        "#panel=content_view_definition_#{version.content_view.content_view_definition.id}&panelpage=views"
  end

  def promotions(num = quantity)
    return  Changeset.joins(:task_status).
        where("#{Katello::Changeset.table_name}.environment_id" => KTEnvironment.changesets_readable(current_organization)).
        order("#{Katello::TaskStatus.table_name}.updated_at DESC").limit(num)
  end

  def changeset_class(cs)
    if cs.state == Changeset::PROMOTED
      "check_icon"
    elsif cs.state == Changeset::PROMOTING && cs.task_status.start_time
      "gears_icon"  #running
    else
      "clock_icon" #pending
    end
  end

  def changeset_message(cs)
    if cs.state == Changeset::PROMOTED
      _("Success")
    elsif cs.state == Changeset::PROMOTING && cs.task_status.start_time
      _("Promoting")
    elsif cs.state == Changeset::FAILED
      _("Failed")
    else
      _("Pending")
    end
  end

  def systems_list(num = quantity)
    System.readable(current_organization).limit(num)
  end

  def changeset_path_helper(cs)
    if cs.state == Changeset::PROMOTED
      katello_changesets_path + "#panel=changeset_#{cs.id}&env_id=#{cs.environment_id}"
    else
      katello_promotion_path(cs.environment.prior.name)
    end
  end

  def products_synced(num = quantity)
    syncing_products = []
    synced_products = []

    Product.readable(current_organization).each do |prod|
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
    case errata[:type]
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
    katello_systems_path + "#list_search=id:#{system.id}&panel=system_#{system.id}&panelpage=errata"
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
      output += content_tag "div", class: "column" do
        render_column(col)
      end
    end
    output.html_safe
  end

  def render_column(column)
    output = ""
    column.each do |widget|
      if widget.content_path
        output += dashboard_ajax_entry(widget.title, widget.name, widget.content_path, "widget", true)
      else
        output += dashboard_entry(widget.title, widget.name, false)
      end
    end
    output.html_safe
  end

  def widget_drag_and_drop_text
    _("Click on the widget title text to drag and drop.")
  end

end
end
