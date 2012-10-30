# provision menu renderer
class ProvisionMenuRenderer < SimpleNavigation::Renderer::Base
  def render(item_container)
    list_content = item_container.items.inject([]) do |list, item|
      li_options = item.html_options.reject {|k, v| k == :link}
      li_content = tag_for(item, options[:subnav])
      if include_sub_navigation?(item)
        li_content << item.sub_navigation.render(self.options.merge({:subnav => true}))
      end
      list << content_tag(:li, li_content, li_options)
    end.join

    if skip_if_empty? && item_container.empty?
      ''
    else
      content_tag(:ul, list_content, {:id => item_container.dom_id, :class => item_container.dom_class})
    end
  end

  protected

  # determine and return link or static content depending on
  # item/renderer conditions.
  def tag_for(item, subnav = false)
    if !subnav
      content = content_tag(:i, '') + content_tag(:div, '', :class=>:arrow_icon_menu)
      content_tag :a, content, link_options_for(item)
    elsif item.url.blank?
      content_tag('span', item.name, link_options_for(item).except(:method))
    else
      link_to(item.name, item.url, link_options_for(item))
    end
  end

  # Extracts the options relevant for the generated link
  def link_options_for(item)
    special_options = {:method => item.method, :class => item.selected_class}.reject {|k, v| v.nil? }
    link_options = item.html_options[:link]
    return special_options unless link_options
    opts = special_options.merge(link_options)
    opts[:class] = [link_options[:class], item.selected_class].flatten.compact.join(' ')
    opts.delete(:class) if opts[:class].nil? || opts[:class] == ''
    opts
  end
end
