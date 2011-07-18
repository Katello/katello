module LayoutHelper
  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args, &block)
    if block
      content_for(:head) { javascript_tag(block.call()) }
    end
    if args
      args.map { |arg| content_for(:head) { include_javascripts(arg) } }
    end
  end
end
