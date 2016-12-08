module Katello
  module Concerns
    module ForemanDocker
      module ContainerStepsHelperExtensions
        extend ActiveSupport::Concern
        def katello_partial(f)
          render(:partial => "/foreman_docker/containers/steps/katello_container", :locals => {:f => f})
        end

        def make_select_box(key, items, spinner_id, options)
          select = collection_select(key, :id, items,
                                     :id, :name, options,
                                     :class => "form-control spinner-form-control"
                                    )
          if spinner_id
            spinner = image_tag("spinner.gif", :id => spinner_id, :class => "hide")
            select + spinner
          else
            select
          end
        end

        def select_container_capsule(f)
          proxies = Organization.current.nil? ? [] : SmartProxy.with_content
          selected_proxy = proxies.size == 1 ? proxies.first.id : nil

          field(f, 'capsule[id]', :label => _("Smart proxy"), :required => true) do
            make_select_box(:capsule,
                             SmartProxy.with_content,
                             "load_capsules",
                             :prompt => _("Select a Smart proxy"),
                             :selected => selected_proxy)
          end
        end

        def select_organizations(f)
          orgs = Organization.authorized(:view_organizations)
          field(f, 'organization[id]', :label => _("Organization"), :required => true) do
            make_select_box(:organization,
                            orgs,
                            nil,
                            :prompt => _("Select an Organization")
                           )
          end
        end

        def select_container_life_cycle_environments(f)
          envs = Organization.current.nil? ? [] : KTEnvironment.readable.where(:organization_id => Organization.current)
          field(f, 'kt_environment[id]', :label => _("Lifecycle Environment"), :required => true) do
            make_select_box(:kt_environment,
                            envs,
                            "load_environments",
                            :prompt => _("Select a Lifecycle Environment")
                           )
          end
        end

        def select_container_content_views(f)
          field(f, 'content_view[id]', :label => _("Content View"), :required => true) do
            make_select_box(:content_view,
                            [],
                            "load_content_views",
                            :prompt => _("Select a Content View")
                           )
          end
        end

        def select_container_cv_repositories(f)
          field(f, 'repository[id]', :label => _("Repository"), :required => true) do
            make_select_box(:repository,
                            [],
                            "load_repositories",
                            :prompt => _("Select a Repository")
                           )
          end
        end

        def select_container_cv_tags(f)
          field(f, 'tag[id]', :label => _("Tag"), :required => true) do
            make_select_box(:tag,
                            [],
                            "load_tags",
                            :prompt => _("Select a Tag")
                           )
          end
        end
      end
    end
  end
end
