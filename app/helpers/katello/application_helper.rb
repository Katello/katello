module Katello
  module ApplicationHelper
    include Katello::LayoutHelper

    def current_user
      User.current
    end

    #formats the date time if the dat is not nil
    def format_time(date, options = {})
      return I18n.l(date, options) if date
      ""
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

    def select_content_view
      _('Select Content View')
    end

    def no_content_view
      _('No Content View')
    end

    def selected_content_view(content_view)
      content_view.nil? ? no_content_view : content_view.id
    end
  end
end
