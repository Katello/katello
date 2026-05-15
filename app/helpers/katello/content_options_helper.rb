module Katello
  module ContentOptionsHelper
    # rubocop:disable Rails/OutputSafety
    # Generic method to provide a list of options in the UI
    def content_options(host, selected_id, object_type, options = {})
      include_blank = options.fetch(:include_blank, nil)
      include_blank = '<option></option>' if include_blank == true #check for true specifically
      orgs = relevant_organizations(host)
      all_options = []
      orgs.each do |org|
        content_object_options = ""
        accessible_content_objects = case object_type
                                     when :lifecycle_environment
                                       accessible_lifecycle_environments(org, host)
                                     when :content_source
                                       accessible_content_proxies(host)
                                     end
        accessible_content_objects.each do |content_object|
          selected = selected_id == content_object.id ? 'selected' : ''
          content_object_options << %(<option value="#{content_object.id}" class="kt-env" #{selected}>#{h(content_object.name)}</option>)
        end

        if orgs.count > 1
          all_options << %(<optgroup label="#{h(org.name)}">#{content_object_options}</optgroup>)
        else
          all_options << content_object_options
        end
      end

      all_options = all_options.join
      all_options.insert(0, include_blank) if include_blank
      all_options.html_safe # User content is safely escaped with h()
    end
    # rubocop:enable Rails/OutputSafety

    def lifecycle_environment_options(host, options = {})
      content_options(
        host,
        fetch_lifecycle_environment(host, options).try(:id),
        :lifecycle_environment,
        options
      )
    end

    def content_source_options(host, options = {})
      content_options(
        host,
        fetch_content_source(host, options).try(:id),
        :content_source,
        options
      )
    end

    # rubocop:disable Rails/OutputSafety
    # Generate <option> tags for Content View Environment dropdown (hostgroups only)
    def content_view_environment_options(hostgroup, options = {})
      include_blank = options.fetch(:include_blank, nil)
      include_blank = '<option></option>' if include_blank == true

      orgs = relevant_organizations(hostgroup)
      current_cvenv = fetch_content_view_environment(hostgroup, options)
      content_source = fetch_content_source(hostgroup, options)

      all_options = build_cvenv_options_for_orgs(orgs, current_cvenv, content_source)
      all_options = all_options.join
      all_options.insert(0, include_blank) if include_blank
      all_options.html_safe # User content is safely escaped with h()
    end
    # rubocop:enable Rails/OutputSafety

    def build_cvenv_options_for_orgs(orgs, current_cvenv, content_source)
      orgs.map do |org|
        cvenvs = fetch_cvenvs_for_org(org, current_cvenv, content_source)
        cvenv_options = build_cvenv_option_tags(cvenvs, current_cvenv)

        if orgs.count > 1
          %(<optgroup label="#{h(org.name)}">#{cvenv_options}</optgroup>)
        else
          cvenv_options
        end
      end
    end

    def fetch_cvenvs_for_org(org, current_cvenv, content_source)
      cvenvs = Katello::ContentViewEnvironment.joins(:content_view, :environment)
               .where("#{Katello::ContentView.table_name}.organization_id" => org.id)
               .order("#{Katello::KTEnvironment.table_name}.name", "#{Katello::ContentView.table_name}.name")
               .to_a

      cvenvs = filter_cvenvs_by_content_source(cvenvs, content_source, org) if content_source.present?
      cvenvs |= [current_cvenv] if current_cvenv.present? && current_cvenv.content_view.organization_id == org.id
      cvenvs
    end

    def filter_cvenvs_by_content_source(cvenvs, content_source, org)
      return cvenvs if content_source.pulp_primary?

      available_env_ids = content_source.lifecycle_environments.where(organization_id: org.id).pluck(:id)
      return cvenvs unless available_env_ids.any?

      cvenvs.select { |cvenv| available_env_ids.include?(cvenv.environment_id) }
    end

    def build_cvenv_option_tags(cvenvs, current_cvenv)
      option_tags = cvenvs.map do |cvenv|
        selected = current_cvenv&.id == cvenv.id ? 'selected' : ''
        label = cvenv.label
        %(<option value="#{cvenv.id}" #{selected}>#{h(label)}</option>)
      end
      option_tags.join
    end

    # rubocop:disable Rails/OutputSafety
    def content_views_for_host(host, options)
      include_blank = options.fetch(:include_blank, nil)
      if include_blank == true #check for true specifically
        include_blank = '<option></option>'
      end
      lifecycle_environment = fetch_lifecycle_environment(host, options)
      content_view = fetch_content_view(host, options)

      views = []
      if lifecycle_environment
        views = Katello::ContentView.in_environment(lifecycle_environment).ignore_generated.readable.order(:name)
        views |= [content_view] if content_view.present? && content_view.in_environment?(lifecycle_environment)
      elsif content_view
        views = [content_view]
      end
      view_options = views.map do |view|
        selected = content_view.try(:id) == view.id ? 'selected' : ''
        %(<option #{selected} value="#{view.id}">#{h(view.name)}</option>)
      end
      view_options = view_options.join
      view_options.insert(0, include_blank) if include_blank
      view_options.html_safe # User content is safely escaped with h()
    end
    # rubocop:enable Rails/OutputSafety

    # rubocop:disable Rails/OutputSafety
    def view_to_options(view_options, selected_val, include_blank = false)
      if include_blank == true #check for true specifically
        include_blank = '<option></option>'
      end
      views = view_options.map do |view|
        selected = selected_val == view.id ? 'selected' : ''
        %(<option #{selected} value="#{view.id}">#{h(view.name)}</option>)
      end
      views = views.join
      views.insert(0, include_blank) if include_blank
      views.html_safe # User content is safely escaped with h()
    end
    # rubocop:enable Rails/OutputSafety

    # rubocop:disable Naming/MethodParameterName
    def blank_or_inherit_with_id(f, attr) # f is Rails convention for form objects
      return true unless f.object.respond_to?(:parent_id) && f.object.parent_id
      inherited_value = f.object.send(attr).try(:id) || ''
      %(<option data-id="#{inherited_value}" value="">#{blank_or_inherit_f(f, attr)}</option>)
    end

    def blank_or_inherit_cvenv(f) # f is Rails convention for form objects
      return true unless f.object.respond_to?(:parent_id) && f.object.parent_id
      parent_cvenv = f.object.parent&.content_view_environment
      inherited_value = parent_cvenv.try(:id) || ''

      if parent_cvenv
        %(<option data-id="#{inherited_value}" value="">#{h(_('Inherit parent (%s)') % parent_cvenv.label)}</option>)
      else
        %(<option value="">#{_('Inherit parent')}</option>)
      end
    end
    # rubocop:enable Naming/MethodParameterName
  end
end
