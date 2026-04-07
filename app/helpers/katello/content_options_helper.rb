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
          all_options << %(<optgroup label="#{org.name}">#{content_object_options}</optgroup>)
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
      current_cve = fetch_content_view_environment(hostgroup, options)
      content_source = fetch_content_source(hostgroup, options)

      all_options = []
      orgs.each do |org|
        # Get all CVEs for this organization
        cves = Katello::ContentViewEnvironment.joins(:content_view, :environment)
                 .where("#{Katello::ContentView.table_name}.organization_id" => org.id)
                 .order("#{Katello::KTEnvironment.table_name}.name", "#{Katello::ContentView.table_name}.name")
                 .to_a

        # Filter by content source availability (if not Pulp primary)
        if content_source.present? && !content_source.pulp_primary?
          available_env_ids = content_source.lifecycle_environments.where(organization_id: org.id).pluck(:id)
          cves = cves.select { |cve| available_env_ids.include?(cve.environment_id) } if available_env_ids.any?
        end

        # Always include the current CVE (even if not on content source - for viewing existing configs)
        cves |= [current_cve] if current_cve.present? && current_cve.content_view.organization_id == org.id

        cve_options = cves.map do |cve|
          selected = current_cve&.id == cve.id ? 'selected' : ''
          label = "#{cve.environment.name} / #{cve.content_view.name}"
          %(<option value="#{cve.id}" #{selected}>#{h(label)}</option>)
        end
        cve_options = cve_options.join

        if orgs.count > 1
          all_options << %(<optgroup label="#{org.name}">#{cve_options}</optgroup>)
        else
          all_options << cve_options
        end
      end

      all_options = all_options.join
      all_options.insert(0, include_blank) if include_blank
      all_options.html_safe # User content is safely escaped with h()
    end
    # rubocop:enable Rails/OutputSafety

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

    def blank_or_inherit_cve(f) # f is Rails convention for form objects
      return true unless f.object.respond_to?(:parent_id) && f.object.parent_id
      parent_cve = f.object.parent&.content_facet&.content_view_environment
      inherited_value = parent_cve.try(:id) || ''

      if parent_cve
        cve_name = "#{parent_cve.environment.name} / #{parent_cve.content_view.name}"
        %(<option data-id="#{inherited_value}" value="">#{_('Inherit parent (%s)') % cve_name}</option>)
      else
        %(<option value="">#{_('Inherit parent')}</option>)
      end
    end
    # rubocop:enable Naming/MethodParameterName
  end
end
