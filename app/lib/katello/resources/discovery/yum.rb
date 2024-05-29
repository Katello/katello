require 'spidr'

module Katello
  module Resources
    module Discovery
      class Yum < RepoDiscovery
        attr_reader :found, :crawled, :to_follow

        # rubocop:disable Metrics/ParameterLists
        def initialize(url, crawled = [], found = [], to_follow = [],
                       upstream_credentials_and_search = {
                         upstream_username: nil,
                         upstream_password: nil,
                       })
          @uri = uri(url)
          @upstream_username = upstream_credentials_and_search[:upstream_username].presence
          @upstream_password = upstream_credentials_and_search[:upstream_password].presence
          @found = found
          @crawled = crawled
          @to_follow = to_follow
        end

        def run(resume_point)
          if @uri.scheme == 'file'
            crawl_file_path(uri(resume_point))
          elsif %w(http https).include?(@uri.scheme)
            spidr_crawl_pages(uri(resume_point))
          end
        end

        private

        def crawl_file_path(url)
          if url.path.ends_with?('/repodata/')
            found_path = Pathname(url.path).parent.to_s
            @found << "file://#{found_path}"
          end
          if url.path == @uri.path
            Dir.glob("#{@uri.path}**/").each { |path| @to_follow << path }
            @to_follow.shift
          end
          @crawled << url.path
        end

        def spidr_proxy_details
          details = {}

          if proxy
            details[:host] = proxy_host
            details[:port] = proxy_port
            details[:user] = proxy.username
            details[:password] = proxy.password
          end

          details
        end

        def spidr_crawl_pages(url)
          url = url.to_s
          user, password = @upstream_username, @upstream_password
          Spidr.site(url, proxy: spidr_proxy_details) do |spider|
            spider.authorized.add(url, user, password) if user && password
            spider.every_page do |page|
              page.url.query = nil
              @crawled << page.url.to_s
              process_page_urls(page.urls)
              spider.skip_page!
            end
          end
        end

        def process_page_urls(urls)
          urls.each do |url|
            # Remove query parameters to avoid duplicate processing of URLs with sorting parameters etc
            url.query = nil
            if url.path.ends_with? 'repodata/'
              @found << url.to_s.split('repodata/').first
            else
              @to_follow << url.to_s if should_follow?(url)
            end
          end
        end

        def should_follow?(url)
          #Verify:
          # * link's path includes the base url
          # * link hasn't already been crawled
          # * link ends with '/' so it should be a directory
          # * link doesn't end with '/Packages/', as this increases
          #       processing time and memory usage considerably
          return url.path.starts_with?(@uri.path) && url.hostname == @uri.hostname && !@crawled.include?(url.to_s) &&
            url.path.ends_with?('/') && !url.path.ends_with?('/Packages/')
        end
      end
    end
  end
end
