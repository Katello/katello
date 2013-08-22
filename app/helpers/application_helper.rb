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



module ApplicationHelper

  include LayoutHelper
  include BrandingHelper
  include NavigationHelper

  def current_url(extra_params={})
    url_for params.merge(extra_params)
  end

  def link_to_authorized(*args, &block)

    if block_given?
      options      = args.first || {}
      html_options = args.second
      link_to_authorized(capture(&block), options, html_options)
    else
      name         = args[0]
      options      = args[1] || {}
      html_options = args[2]


      if options.key? :controller
        ctrl   = options[:controller]
        action = options[:action] || 'index'

        if current_user and current_user.allowed_to?({:controller => ctrl, :action => action})
          link_to(name, options, html_options)
        end
      end
    end

  end

  def help_tip(text, key=nil)
    key ||= params[:controller] + "-" + params[:action]
    render :partial => "common/helptip", :locals=>{:key=>key, :text=>text}
  end

  def help_tip_button(key=nil)
    key ||= params[:controller] + "-" + params[:action]
    render :partial => "common/helptip_button", :locals=>{:key=>key}
  end

  # Headpin inclusion
  def stats_line(stats, options ={})
    render :partial => "common/stats_line",
      :locals => {:stats => stats}
  end

  # Headpin inclusion
  def to_value_list(stats)
    list = ""
    prepend = ""
    stats.each do |stat|
      list += prepend
      prepend = ","
      list += stat.value.to_s
    end
    list
  end

  def two_panel(collection, options)
    options[:accessor] ||= "id"
    options[:left_panel_width] ||= nil
    options[:ajax_load] ||= false
    enable_create = options[:enable_create]
    enable_create = true if enable_create.nil?
    enable_sort = options[:enable_sort] ? options[:enable_sort] : false

    raise ":titles option not provided" unless options[:titles]

    render :partial => "common/panel",
           :locals => {
             :title => options[:title],
             :name => options[:name],
             :create => options[:create],
             :enable_create => enable_create,
             :create_label => options[:create_label] || nil,
             :enable_sort => enable_sort,
             :columns => options[:col],
             :titles => options[:titles],
             :custom_rows => options[:custom_rows],
             :collection => collection,
             :accessor=>options[:accessor],
             :url=>options[:url],
             :left_panel_width=>options[:left_panel_width],
             :ajax_load => options[:ajax_load],
             :ajax_scroll =>options[:ajax_scroll],
             :search_env =>options[:search_env],
             :initial_action=>options[:initial_action] || :edit,
             :initial_state=>options[:initial_state] || false,
             :actions=>options[:actions],
             :search_class=>options[:search_class],
             :disable_create=>options[:disable_create] || false}
  end

  def one_panel(panel_id, collection, options)
    options[:accessor] ||= "id"
    panel_id ||= "panel"

    render :partial => "common/one_panel",
           :locals => {
             :single_select => options[:single_select] || false,
             :hover_text_cb => options[:hover_text_cb],
             :panel_id => panel_id,
             :title => options[:title],
             :name => options[:name],
             :columns => options[:col],
             :column_titles => options[:col_titles],
             :custom_rows => options[:custom_rows],
             :collection => collection,
             :accessor=>options[:accessor] }
  end

  def notification_polling_time
    time  = Katello.config.notification && Katello.config.notification.polling_seconds
    return time.to_i  * 1000 if time
    return 120000
  end

  def environment_selector options = {}
    options[:library_clickable] = true if options[:library_clickable].nil? # ||= doesn't work if false
    options[:url_proc] = nil if options[:url_proc].nil? #explicitly set url_method to nil if not provided

    # the path widget and entries classes allow the user to override the classes that will be applied to these
    # elements.  by default, they are set assuming the env selector will be displayed on a page (vs w/in a panel)
    options[:path_widget_class] = "" if options[:path_widget_class].nil?
    options[:path_entries_class] = "grid_10" if options[:path_entries_class].nil?

    # allow user to include additional data attributes (urls) to retrieve other elements from the env, such as
    # products and content views
    options[:url_products_proc] = nil if options[:url_products_proc].nil?
    options[:url_content_views_proc] = nil if options[:url_content_views_proc].nil?

    render :partial=>"/common/env_select", :locals => options
  end

  def gravatar_image_tag(email)
    image_url = gravatar_url(email)
    return "<img src=\"#{image_url}\" class=\"gravatar\"><span class=\"gravatar-span\">"
  end

  def gravatar_url(email)
    "https:///secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?d=mm&s=25"
  end

  def env_select_class curr_env, selected_env, curr_path, selected_path, accessible_envs, library_clickable
    classes = []
    if (library_clickable || !curr_env.library?) and accessible_envs.member?(curr_env)
      classes << "path_link"
    else
      # if library isn't clickable, disable the hover effect
      classes << "crumb-nohover"
    end

    if curr_env.id == selected_env.id
      if !selected_env.library?
        classes << "active"
      else
        #we only want to highlight the Library along the path that is actually selected
        classes << "active" if curr_path[1] == selected_path[1]
      end
    end
    classes.join(' ')
  end

  def env_select_url proc, env, next_env, org
    return nil if proc.nil?
    proc.call(:environment=> env, :next_environment=>next_env, :organization=>org)
  end

  # auto_tab_index: this method may be used to simplify adding a tabindex to UI forms.
  def auto_tab_index
    @current_index ||= 0
    @current_index += 1
  end

  #formats the date time if the dat is not nil
  def format_time  date, options = {}
    return I18n.l(date, options) if date
    ""
  end

  def generate_url(path, options, entity)
    panel_page = options.has_key?(:panel_page) ? ("&panelpage=" + options[:panel_page]) : ""
    path + "?list_search=id%3D#{options[:id]}#panel=#{entity}_#{options[:id]}" + panel_page
  end

  # used for jeditable fields
  def editable_class(editable = false)
    return "editable edit_panel_element multiline" if editable
    "multiline"
  end

  #returns a proc to generate a url for the env_selector
  def url_products_proc
    lambda{|args|
      products_organization_environment_path(args[:organization].label, args[:environment].id)
    }
  end

  def url_content_views_proc
    lambda do |args|
      content_views_organization_environment_path(args[:organization].label, args[:environment].id)
    end
  end

  # These 2 methods copied from scoped_search {https://github.com/wvanbergen/scoped_search}
  # which Katello used to use but no longer uses.
  #
  # Creates a link that alternates between ascending and descending.
  #
  # @example
  #   sort @search, :by => :username
  #   sort @search, :by => :created_at, :as => "Created"
  #
  # @param [Hash] options This helper accepts the following options:
  # @option options [String] :by the name of the named scope. This helper will prepend this value with "ascend_by_" and "descend_by_"
  # @option options [String] :as the text used in the link, defaults to whatever is passed to :by
  def sort(field, options = {}, html_options = {})

    unless options[:as]
      id           = field.to_s.downcase == "id"
      options[:as] = id ? field.to_s.upcase : field.to_s.humanize
    end

    ascend  = "#{field}|ASC"
    descend = "#{field}|DESC"

    ascending = params[:order] == ascend
    new_sort = ascending ? descend : ascend
    selected = [ascend, descend].include?(params[:order])

    if selected
      css_classes = html_options[:class] ? html_options[:class].split(" ") : []
      if ascending
        options[:as] = "&#9650;&nbsp;#{options[:as]}"
        css_classes << "ascending"
      else
        options[:as] = "&#9660;&nbsp;#{options[:as]}"
        css_classes << "descending"
      end
      html_options[:class] = css_classes.join(" ")
    end

    url_options = params.merge(:order => new_sort)

    options[:as] = raw(options[:as]) if defined?(RailsXss)

    a_link(options[:as], html_escape(url_for(url_options)),html_options)
  end

  def a_link(name, href, html_options)
    tag_options = tag_options(html_options)
    link = "<a href=\"#{href}\"#{tag_options}>#{name}</a>"
    return link.respond_to?(:html_safe) ? link.html_safe : link
  end

  # If no provider_id is specified, it is assumed to be a Red Hat subscription and the link returned
  # goes to the subscriptions page. Alternatively, if the distinction between the Red Hat provider and
  # a custom provider is important, pass in the provider_id and the current org.
  def subscriptions_pool_link_helper pool_name, pool_id, provider_id, org
    if provider_id == org.redhat_provider.id
      link_to pool_name, subscriptions_path(:anchor => "/!=&panel=subscription_#{pool_id}")
    elsif !provider_id.nil?
      link_to pool_name, providers_path(:anchor => "/!=&panel=provider_#{provider_id}")
    else
      pool_name
    end
  end

  def kt_form_for(object, options = {}, &block)
    if current_user.experimental_ui
      options[:builder] = Experimental::KatelloFormBuilder
      options[:html] = { :class => "form" }
    else
      options[:builder] = KatelloFormBuilder
    end
    form_for(object, options, &block)
  end

  def select_content_view
    _('Select Content View')
  end

  def no_content_view
    _('No Content View')
  end

  def content_view_select_labels(organization, environment)
    if environment
      labels = ContentView.readable(organization).
          in_environment(environment).collect {|cv| [cv.name, cv.id]}
    else
      labels = []
    end
    labels
  end

  def selected_content_view(content_view)
    content_view.nil? ? no_content_view : content_view.id
  end

  def to_calendar_date(date)
    date.strftime('%m/%d/%Y')
  end

  def subscription_limits_helper(sub)
    lim = []
    lim << _("Sockets: %s") % sub.sockets if sub.sockets > 0
    lim << _("Cores: %s") % sub.cores if sub.cores > 0
    lim << _("RAM: %s GB") % sub.ram if sub.ram > 0
    lim.join(", ")
  end

  def default_description_limit
    return Validators::KatelloDescriptionFormatValidator::MAX_LENGTH
  end
end


