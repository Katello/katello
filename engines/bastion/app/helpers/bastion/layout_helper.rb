module Bastion
  module LayoutHelper
    def include_plugin_js(plugin)
      return unless plugin[:javascript]

      if plugin[:javascript].is_a?(Proc)
        js = instance_eval(&plugin[:javascript])
        js = js.join("\n") if js.is_a?(Array)
        js.html_safe
      else
        javascript_include_tag(plugin[:javascript])
      end
    end

    def include_plugin_styles(plugin)
      return unless plugin[:stylesheet]

      if plugin[:stylesheet].is_a?(Proc)
        styles = instance_eval(&plugin[:stylesheet])
        styles = styles.join("\n") if styles.is_a?(Array)
        styles.html_safe
      else
        stylesheet_link_tag(plugin[:stylesheet])
      end
    end
  end
end
