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
  module ApplicationHelper
    include Katello::LayoutHelper

    def current_user
      User.current
    end

    def current_url(extra_params = {})
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

          if current_user && current_user.allowed_to?(:controller => ctrl, :action => action)
            link_to(name, options, html_options)
          end
        end
      end
    end

    def help_tip(text, key = nil)
      key ||= params[:controller] + "-" + params[:action]
      render :partial => "katello/common/helptip", :locals => {:key => key, :text => text}
    end

    def help_tip_button(key = nil)
      key ||= params[:controller] + "-" + params[:action]
      render :partial => "katello/common/helptip_button", :locals => {:key => key}
    end

    # Headpin inclusion
    def stats_line(stats, _options = {})
      render :partial => "katello/commonstats_line",
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

      fail ":titles option not provided" unless options[:titles]

      render :partial => "katello/common/panel",
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
               :accessor => options[:accessor],
               :url => options[:url],
               :left_panel_width => options[:left_panel_width],
               :ajax_load => options[:ajax_load],
               :ajax_scroll => options[:ajax_scroll],
               :search_env => options[:search_env],
               :initial_action => options[:initial_action] || :edit,
               :initial_state => options[:initial_state] || false,
               :actions => options[:actions],
               :search_class => options[:search_class],
               :disable_create => options[:disable_create] || false}
    end

    def one_panel(panel_id, collection, options)
      options[:accessor] ||= "id"
      panel_id ||= "panel"

      render :partial => "katello/common/one_panel",
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
               :accessor => options[:accessor] }
    end

    def notification_polling_time
      time  = Katello.config.notification && Katello.config.notification.polling_seconds
      return time.to_i  * 1_000 if time
      return 120_000
    end

    def environment_selector(options = {})
      options[:library_clickable] = true if options[:library_clickable].nil? # ||= doesn't work if false
      options[:url_proc] = nil if options[:url_proc].nil? #explicitly set url_method to nil if not provided

      # the path widget and entries classes allow the user to override the classes that will be applied to these
      # elements.  by default, they are set assuming the env selector will be displayed on a page (vs w/in a panel)
      options[:path_widget_class] = "" if options[:path_widget_class].nil?
      options[:path_entries_class] = "grid_10" if options[:path_entries_class].nil?

      render :partial => "/katello/common/env_select", :locals => options
    end

    def env_select_class(curr_env, selected_env, curr_path, selected_path, accessible_envs, library_clickable)
      classes = []
      if (library_clickable || !curr_env.library?) && accessible_envs.member?(curr_env)
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

    def env_select_url(proc, env, next_env, org)
      return nil if proc.nil?
      proc.call(:environment => env, :next_environment => next_env, :organization => org)
    end

    # auto_tab_index: this method may be used to simplify adding a tabindex to UI forms.
    def auto_tab_index
      @current_index ||= 0
      @current_index += 1
    end

    #formats the date time if the dat is not nil
    def format_time(date, options = {})
      return I18n.l(date, options) if date
      ""
    end

    def generate_url(path, options, entity)
      panel_page = options.key?(:panel_page) ? ("&panelpage=" + options[:panel_page]) : ""
      path + "?list_search=id%3D#{options[:id]}#panel=#{entity}_#{options[:id]}" + panel_page
    end

    # used for jeditable fields
    def editable_class(editable = false)
      return "editable edit_panel_element multiline" if editable
      "multiline"
    end

    # These 2 methods copied from scoped_search {https://github.com/wvanbergen/scoped_search}
    # which Katello used to use but no longer uses.
    #
    # Creates a link that alternates between ascending and descending.
    #
    # @example
    #   sort @search, :by => :login
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

      a_link(options[:as], html_escape(url_for(url_options)), html_options)
    end

    def a_link(name, href, html_options)
      tag_options = tag_options(html_options)
      link = "<a href=\"#{href}\"#{tag_options}>#{name}</a>"
      return link.respond_to?(:html_safe) ? link.html_safe : link
    end

    def distributor_link_helper(distributor_id)
      distributor = Distributor.find(distributor_id)
      if distributor.readable?
        link_to(distributor.name, distributors_path(distributor.id, :anchor => "/&list_search=id:#{distributor.id}&panel=distributor_#{distributor.id}"))
      else
        distributor.name
      end
    rescue ActiveRecord::RecordNotFound
      _('Distributor with uuid %s not found') % distributor_id
    end

    def activation_key_link_helper(key)
      if ActivationKey.readable? key.organization
        link_to(key.name, activation_keys_path(key.id, :anchor => "/&list_search=id:#{key.id}&panel=activation_key_#{key.id}"))
      else
        key.name
      end
    rescue
      _('Activation key with uuid %s not found') % key.try(:id)
    end

    def kt_form_for(object, options = {}, &block)
      options[:builder] = KatelloFormBuilder
      form_for(object, options, &block)
    end

    def select_content_view
      _('Select Content View')
    end

    def no_content_view
      _('No Content View')
    end

    def content_view_select_labels(_organization, environment)
      if environment
        labels = ContentView.readable.
            in_environment(environment).collect { |cv| [cv.name, cv.id] }
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

    def repo_selector(repositories, url, field = :repository_id, record = nil)
      products = repositories.map(&:product).uniq.sort_by { |product| product[:name] }
      repo_ids = repositories.map(&:id)

      content_tag "select", :id => "repo_select", :name => field, "data-url" => url do
        html = ""
        html << content_tag("option", :value => "") { "None" }

        groups = products.map do |prod|
          content_tag("optgroup", :label => "#{h(prod.name)}") do
            options = prod.repositories.select { |repo| repo_ids.include?(repo.id) }.map do |repo|
              selected = record && record.send(field) == repo.id

              content_tag("option", :value => repo.id, :selected => selected) do
                h(repo.name)
              end
            end
            options.join.html_safe
          end
        end

        (html + groups.join).html_safe
      end
    end

    # Using the record provided, return a hash where the
    # keys are the products associated with the record and the
    # values are arrays listing the repositories associated
    # with the given product.
    # For example: {product1 => [repo1, repo2]}
    def get_product_and_repos(record, content_types)
      products_hash = record.resulting_products.inject({}) do |hash, product|
        if record.repositories.empty?
          hash[product] = []
        else
          repos = product.repos(current_organization.library).where(:content_type => content_types)
          repos.each do |repo|
            hash[product] ||= []
            hash[product] << repo
          end
        end
        hash
      end

      products_hash
    end
  end
end
