module LayoutHelper
  def stylesheet(*args)
    args.map { |arg| content_for(:stylesheets) { include_javascripts(arg) } }
  end

  def javascript(*args, &block)
    if block
      content_for(:javascripts) { javascript_tag(block.call()) }
    end
    if args
      args.map { |arg| content_for(:javascripts) { include_javascripts(arg) } }
    end
  end
end
