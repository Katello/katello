module Katello
  module HostsAndHostgroupsHelper
    def kt_ak_label
      "kt_activation_keys"
    end

    def blank_or_inherit_with_id(f, attr)
      return true unless f.object.respond_to?(:parent_id) && f.object.parent_id
      inherited_value  = f.object.send(attr).try(:id) || ''
      %(<option data-id="#{inherited_value}" value="">#{blank_or_inherit_f(f, attr)}</option>)
    end

    def envs_by_kt_org
      ::Environment.all.find_all(&:katello_id).group_by do |env|
        if env.katello_id
          env.katello_id.split('/').first
        end
      end
    end

    def lifecycle_environment_options(host, options = {})
      include_blank = options.fetch(:include_blank, nil)
      if include_blank == true #check for true specifically
        include_blank = '<option></option>'
      end
      selected_id = host.content_aspect(:lifecycle_environment).try(:id)
      orgs = Organization.current ? [Organization.current] : Organization.my_organizations
      all_options = []
      orgs.each do |org|
        env_options = ""
        org.kt_environments.each do |env|
          selected = selected_id == env.id ? 'selected' : ''
          env_options << %(<option value="#{env.id}" class="kt-env" #{selected}>#{h(env.name)}</option>)
        end

        if Organization.current
          all_options << env_options
        else
          all_options <<  %(<optgroup label="#{org.name}">#{env_options}</optgroup>)
        end
      end

      all_options = all_options.join
      all_options.insert(0, include_blank) if include_blank
      all_options.html_safe
    end

    def content_views_for_host(host, options)
      include_blank = options.fetch(:include_blank, nil)
      if include_blank == true #check for true specifically
        include_blank = '<option></option>'
      end

      content_view = host.content_aspect.try(:content_view)
      views = []
      if host.content_aspect.try(:lifecycle_environment)
        views = Katello::ContentView.in_environment(host.content_aspect.try(:lifecycle_environment))
      elsif content_view
        views = [content_view]
      end
      view_options = views.map do |view|
        selected = content_view.try(:id) == view.id ? 'selected' : ''
        %(<option #{selected} value="#{view.id}">#{h(view.name)}</option>)
      end
      view_options = view_options.join
      view_options.insert(0, include_blank) if include_blank
      view_options.html_safe
    end
  end
end
