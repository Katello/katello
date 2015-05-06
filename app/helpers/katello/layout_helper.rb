module Katello
  module LayoutHelper
    def stylesheet(*args)
      args.map { |arg| content_for(:stylesheets) { stylesheet_link_tag(arg) } }
      return ""
    end

    def javascript(*args, &block)
      if block
        content_for(:inline_javascripts) { block.call }
      end
      if args
        args.map { |arg| content_for(:katello_javascripts) { javascript_include_tag(arg) } }
      end
      return ""
    end

    def trunc_with_tooltip(text, length = 32)
      text    = text.to_s
      options = text.size > length ? { :'data-original-title' => text, :rel => 'twipsy' } : {}
      content_tag(:span, truncate(text, :length => length), options).html_safe
    end
  end
end
