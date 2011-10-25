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
  include ScopedSearch::RailsHelper

  #require 'navigation/main'

  #include Navigation



  def current_url(extra_params={})
    url_for params.merge(extra_params)
  end

  def project_name
    _("Katello")
  end
  
  def default_title
    _("Open Source Systems Management")
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
    enable_create = options[:enable_create]
    enable_create = true if enable_create.nil?
    enable_sort = options[:enable_sort] ? options[:enable_sort] : false
    render :partial => "common/panel", 
           :locals => {
             :title => options[:title], 
             :name => options[:name], 
             :create => options[:create],
             :enable_create => enable_create,
             :enable_sort => enable_sort,
             :columns => options[:col],
             :custom_rows => options[:custom_rows],
             :collection => collection,
             :accessor=>options[:accessor],
             :url=>options[:url], 
             :left_panel_width=>options[:left_panel_width],
             :ajax_scroll =>options[:ajax_scroll],
             :search_env =>options[:search_env]}
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
 
 def notification_polling_time()
    time  = AppConfig.notification && AppConfig.notification.polling_seconds
    return time.to_i  * 1000 if time
    return 120000
 end

  def environment_selector options = {}
    options[:locker_clickable] = true if options[:locker_clickable].nil? # ||= doesn't work if false
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

  def env_select_class curr_env, selected_env, curr_path, selected_path, accessible_envs, locker_clickable
    classes = []
    if (locker_clickable or !curr_env.locker?) and accessible_envs.member?(curr_env)
      classes << "path_link"
    else
      # if locker isn't clickable, disable the hover effect
      classes << "crumb-nohover"
    end

    if curr_env.id == selected_env.id
      if !selected_env.locker?
        classes << "active"
      else
        #we only want to higlight the Locker along the path that is actually selected
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
  def format_time  date
    return date.localtime.strftime('%m/%d/%y %I:%M %p %Z') if date
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
end
