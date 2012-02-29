#
# Copyright 2011 Red Hat, Inc.
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

  #require 'navigation/main'

  #include Navigation

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

  def include_common_i18n
    render :partial => "common/common_i18n"
  end

  def include_editable_i18n
    render :partial=> "common/edit_i18n"
  end
 
  def notification_polling_time
    time  = AppConfig.notification && AppConfig.notification.polling_seconds
    return time.to_i  * 1000 if time
    return 120000
  end

  def environment_selector options = {}
    options[:library_clickable] = true if options[:library_clickable].nil? # ||= doesn't work if false
    options[:url_proc] = nil if options[:url_proc].nil? #explicitly set url_method to nil if not provided

    # the path widget and entries classes allow the user to override the classes that will be applied to these
    # elements.  by default, they are set assuming the env selector will be displayed on a page (vs w/in a panel)
    options[:path_widget_class] = "grid_10 prefix_3 suffix_3" if options[:path_widget_class].nil?
    options[:path_entries_class] = "grid_10" if options[:path_entries_class].nil?

    # allow user to include additional data attributes (urls) to retrieve other elements from the env, such as
    # products and system templates
    options[:url_templates_proc] = nil if options[:url_templates_proc].nil?
    options[:url_products_proc] = nil if options[:url_products_proc].nil?

    render :partial=>"/common/env_select", :locals => options
  end

  def env_select_class curr_env, selected_env, curr_path, selected_path, accessible_envs, library_clickable
    classes = []
    if (library_clickable or !curr_env.library?) and accessible_envs.member?(curr_env)
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

  def get_new_notices
    {:new_notices=>current_user.pop_notices}
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

  def generate_details_url(path, id, entity )
     path + "?search=id%3D#{id}#panel=#{entity}_#{id}"
  end

  # used for jeditable fields
  def editable_class(editable = false)
    return "editable edit_panel_element multiline" if editable
    "multiline"
  end

  #returns a proc to generate a url for the env_selector
  def url_templates_proc
    lambda{|args|
      system_templates_organization_environment_path(args[:organization].cp_key, args[:environment].id)
    }
  end

  #returns a proc to generate a url for the env_selector
  def url_products_proc
    lambda{|args|
      products_organization_environment_path(args[:organization].cp_key, args[:environment].id)
    }
  end


  # These 2 methods copied from scoped_search:
  #
  #  https://github.com/wvanbergen/scoped_search
  #
  # which Katello used to use but no longer uses.
  #
  # Creates a link that alternates between ascending and descending.
  #
  # Examples:
  #
  #   sort @search, :by => :username
  #   sort @search, :by => :created_at, :as => "Created"
  #
  # This helper accepts the following options:
  #
  # * <tt>:by</tt> - the name of the named scope. This helper will prepend this value with "ascend_by_" and "descend_by_"
  # * <tt>:as</tt> - the text used in the link, defaults to whatever is passed to :by
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


end
