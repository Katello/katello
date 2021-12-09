module Katello
  module Resources
    module CDN
      class KatelloCdn < CdnResource
        def initialize(url, options)
          @organization_label = options.delete(:organization_label)
          @content_view_label = options.delete(:content_view_label)
          @lifecycle_environment_label = options.delete(:lifecycle_environment_label)
          fail ArgumentError, "No upstream organization was specified" if @organization_label.nil?

          super
        end

        def fetch_paths(content_path)
          url = "/katello/api/v2/repository_sets?organization_id=#{organization['id']}&search=#{CGI.escape("path = #{content_path}")}"
          response = get(url)
          repo_set = JSON.parse(response)['results'].first

          fail _("Upstream organization %s does not provide this content path") % @organization_label if repo_set.nil?

          # now get available repositories when we know the upstream repo set ID
          url = "/katello/api/v2/repository_sets/#{repo_set['id']}/available_repositories?organization_id=#{organization['id']}"
          response = get(url)
          json_body = JSON.parse(response)
          results = json_body['results']

          results.map do |r|
            {
              path: r['path'],
              substitutions: r['substitutions']
            }
          end
        end

        def valid_path?(_path, _postfix)
          true
        end

        def debug_certificate
          get("/katello/api/v2/organizations/#{organization['id']}/download_debug_certificate")
        end

        def content_view_id
          rs = get("/katello/api/v2/organizations/#{organization['id']}/content_views?name=#{CGI.escape(@content_view_label)}")
          content_view = JSON.parse(rs)['results']&.first
          if content_view.blank?
            fail _("Upstream organization %{org_label} does not have a content view with the label %{cv_label}") % { org_label: @organization_label,
                                                                                                                     cv_label: @content_view_label }
          end
          content_view["id"]
        end

        def lifecycle_environment_id
          rs = get("/katello/api/v2/organizations/#{organization['id']}/environments")
          env = JSON.parse(rs)['results'].find { |lce| lce['label'] == @lifecycle_environment_label }

          if env.blank?
            fail _("Upstream organization %{org_label} does not have a lifecycle environment with the label %{lce_label}") % { org_label: @organization_label,
                                                                                                                               lce_label: @lifecycle_environment_label }
          end
          env["id"]
        end

        def repository_url(content_label:)
          params = {
            search: CGI.escape("content_label = #{content_label}")
          }

          params[:content_view_id] = content_view_id if @content_view_label
          params[:environment_id] = lifecycle_environment_id if @lifecycle_environment_label

          query_params = params.map { |key, value| "#{key}=#{value}" }
          url = "/katello/api/v2/organizations/#{organization['id']}/repositories?#{query_params.join('&')}"
          response = get(url)
          repository = JSON.parse(response)['results'].first

          if repository.nil?
            msg_params = { content_label: content_label,
                           org_label: @organization_label,
                           cv_label: @content_view_label || Katello::OrganizationCreator::DEFAULT_CONTENT_VIEW_LABEL,
                           env_label: @lifecycle_environment_label || Katello::OrganizationCreator::DEFAULT_LIFECYCLE_ENV_LABEL
            }

            fail _("Repository with content label %{content_label} was not found in upstream organization %{org_label},"\
                   " content view %{cv_label} and lifecycle environment %{env_label} ") % msg_params
          end
          repository['full_path']
        end

        private

        def organization
          @organization ||= find_organization(@organization_label)
        end

        def find_organization(label)
          response = get("/api/v2/organizations?search=#{CGI.escape("label = #{label}")}")
          JSON.parse(response)['results'].first
        rescue => e
          Rails.logger.error("Couldn't load upstream organization with label=#{label} error=#{e.message}")
          raise e
        end
      end
    end
  end
end
