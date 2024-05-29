module Katello
  module Resources
    module CDN
      class KatelloCdn < CdnResource
        def initialize(url, options)
          @organization_label = options.delete(:organization_label)
          @content_view_label = options.delete(:content_view_label) || ::Katello::OrganizationCreator::DEFAULT_CONTENT_VIEW_LABEL
          @lifecycle_environment_label = options.delete(:lifecycle_environment_label) || ::Katello::OrganizationCreator::DEFAULT_LIFECYCLE_ENV_LABEL
          fail ArgumentError, "No upstream organization was specified" if @organization_label.nil?

          super
        end

        def fetch_repo_set(content_path)
          url = "/katello/api/v2/repository_sets?organization_id=#{organization['id']}&search=#{CGI.escape("path = #{content_path}")}"
          response = get(url)
          JSON.parse(response)['results'].first
        end

        def fetch_paths(content_path)
          repo_set = fetch_repo_set(content_path)

          fail _("Upstream organization %s does not provide this content path") % @organization_label if repo_set.nil?

          params = {
            full_result: true,
            organization_id: organization['id'],
            content_view_id: content_view_id,
            environment_id: lifecycle_environment_id,
            search: CGI.escape("content_label = #{repo_set['label']}"),
          }
          query_params = params.map { |key, value| "#{key}=#{value}" }

          url = "/katello/api/v2/repositories?#{query_params.join("&")}"
          response = get(url)
          json_body = JSON.parse(response)
          results = json_body['results']

          results.map do |repo|
            Katello::Content.substitute_content_path(arch: repo['arch'],
                                                     releasever: repo['minor'],
                                                     content_path: content_path)
          end
        end

        def valid_path?(_path, _postfix)
          true
        end

        def validate!
          organization && content_view_id && lifecycle_environment_id
        end

        def debug_certificate
          get("/katello/api/v2/organizations/#{organization['id']}/download_debug_certificate")
        end

        def content_view_id
          rs = get("/katello/api/v2/organizations/#{organization['id']}/content_views?search=#{CGI.escape("label=#{@content_view_label}")}")
          content_view = JSON.parse(rs)['results']&.first
          if content_view.blank?
            fail _("Upstream organization %{org_label} does not have a content view with the label %{cv_label}") % { org_label: @organization_label,
                                                                                                                     cv_label: @content_view_label }
          end
          content_view["id"]
        end

        def lifecycle_environment_id
          rs = get("/katello/api/v2/organizations/#{organization['id']}/environments?full_result=true")
          env = JSON.parse(rs)['results'].find { |lce| lce['label'] == @lifecycle_environment_label }

          if env.blank?
            fail _("Upstream organization %{org_label} does not have a lifecycle environment with the label %{lce_label}") % { org_label: @organization_label,
                                                                                                                               lce_label: @lifecycle_environment_label }
          end
          env["id"]
        end

        def repository_url(content_label:, arch:, major:, minor:)
          params = {
            search: CGI.escape("content_label = #{content_label}"),
          }

          params[:content_view_id] = content_view_id if @content_view_label
          params[:environment_id] = lifecycle_environment_id if @lifecycle_environment_label

          query_params = params.map { |key, value| "#{key}=#{value}" }
          url = "/katello/api/v2/organizations/#{organization['id']}/repositories?#{query_params.join('&')}"
          response = get(url)
          repository = JSON.parse(response)['results']&.find { |r| r['arch'] == arch && r['major'] == major && r['minor'] == minor }
          if repository.nil?
            msg_params = { content_label: content_label,
                           arch: arch,
                           major: major,
                           minor: minor,
                           org_label: @organization_label,
                           cv_label: @content_view_label || Katello::OrganizationCreator::DEFAULT_CONTENT_VIEW_LABEL,
                           env_label: @lifecycle_environment_label || Katello::OrganizationCreator::DEFAULT_LIFECYCLE_ENV_LABEL,
            }

            fail _("Repository with content label: '%{content_label}'#{arch ? ', arch: \'%{arch}\'' : ''}#{minor ? ', version: \'%{minor}\'' : ''} was not found in upstream organization '%{org_label}',"\
                   " content view '%{cv_label}' and lifecycle environment '%{env_label}'") % msg_params
          end
          repository['full_path']
        end

        private

        def organization
          @organization ||= find_organization(@organization_label)
        end

        def find_organization(label)
          response = get("/api/v2/organizations?search=#{CGI.escape("label = #{label}")}")
          JSON.parse(response)['results'].first.tap do |org|
            fail "Specified organization was not found: #{label}" if org.nil?
          end
        rescue => e
          Rails.logger.error("Couldn't load upstream organization with label=#{label} error=#{e.message}")
          raise e
        end
      end
    end
  end
end
