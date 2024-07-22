module Katello
  module Resources
    module Discovery
      class Container < RepoDiscovery
        attr_reader :found, :crawled, :to_follow

        # rubocop:disable Metrics/ParameterLists
        def initialize(url, crawled = [], found = [], to_follow = [],
                       upstream_credentials_and_search = {
                         upstream_username: nil,
                         upstream_password: nil,
                         search: '*',
                       })
          @uri = uri(url)
          @upstream_username = upstream_credentials_and_search[:upstream_username].presence
          @upstream_password = upstream_credentials_and_search[:upstream_password].presence
          @search = upstream_credentials_and_search.fetch(:search, '*')
          @found = found
          @crawled = crawled
          @to_follow = to_follow
        end

        def run(_resume_point)
          docker_search
        end

        private

        def parse_parameter(field_value)
          field_value.lstrip!
          i = field_value.index(/[ \t=;,]/) || field_value.length
          name = field_value.slice!(0, i).downcase(:ascii)
          field_value.lstrip!
          if field_value.delete_prefix!('=')
            field_value.lstrip!
            if field_value.delete_prefix!('"')
              value = ''
              until field_value.empty?
                break if field_value.delete_prefix!('"')
                field_value.delete_prefix!("\\")
                value += field_value.slice!(0, 1) || ''
              end
            else
              i = field_value.index(/[;,]/) || field_value.length
              value = field_value.slice!(0, i)
            end
          end
          {name: name, value: value || ''}
        end

        def parse_parameters(field_value)
          seen_rel = false
          has_next_rel = false
          has_anchor = false
          until field_value.empty?
            field_value.lstrip!
            break if field_value.delete_prefix!(';').nil?
            param = parse_parameter(field_value)
            case
            when param[:name] == 'rel' && !seen_rel
              seen_rel = true
              has_next_rel = param[:value].downcase(:ascii).split(/[ \t]/).include?('next')
            when param[:name] == 'anchor'
              has_anchor = true
            end
          end
          {has_next_rel: has_next_rel, has_anchor: has_anchor}
        end

        def get_next_link(link_header)
          # This code mostly follows Appendix B "Algorithms of Parsing Link Header Fields" of RFC 8288
          # "Web Linking", <https://www.rfc-editor.org/rfc/rfc8288#appendix-B> (that RFC appears to be
          # silent about multiple "next" links, so just use the first one and ignore any additional
          # ones, in the general spirit of being lenient):
          return nil if link_header.nil?
          field_value = link_header.clone
          until field_value.empty?
            # The following ignores any junk preceding the next <...> link URL:
            m = field_value.match(/<(.*)>/)
            break unless m
            target_string = m[1]
            field_value = m.post_match
            params = parse_parameters(field_value)
            if params[:has_next_rel]
              # To keep it simple, ignore a link with an (unlikely) anchor parameter; but the RFC
              # mandates that we "MUST NOT process the link without applying the anchor", so just raise
              # an exception in that (unlikely) case:
              fail "anchor not supported" if params[:has_anchor]
              return target_string
            end
          end
          nil
        end

        def docker_search
          request_params = {
            method: :get,
            headers: { accept: :json },
            url: "#{@uri}v1/search?q=#{@search}",
          }

          request_params[:user] = @upstream_username if @upstream_username
          request_params[:password] = @upstream_password if @upstream_password
          request_params[:proxy] = proxy_uri if proxy

          begin
            results = RestClient::Request.execute(request_params)
            JSON.parse(results)['results'].each do |result|
              @found << result['name']
            end
          rescue
            # Note: v2 endpoint does not support search
            request_params[:url] = "#{@uri}v2/_catalog"
            loop do
              results = RestClient::Request.execute(request_params)
              JSON.parse(results)['repositories'].each do |result|
                @found << result
              end
              next_uri = get_next_link(results.headers[:link])
              break if next_uri.nil?
              request_params[:url] = URI(request_params[:url]).merge(next_uri).to_s
            end
          end
          @found.sort!
        end
      end
    end
  end
end
