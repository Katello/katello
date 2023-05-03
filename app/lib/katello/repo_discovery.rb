module Katello
  class RepoDiscovery
    include Katello::Util::HttpProxy

    attr_reader :found, :crawled, :to_follow

    # rubocop:disable Metrics/ParameterLists
    def initialize(url, content_type = 'yum', upstream_username = nil,
      upstream_password = nil, search = '*', crawled = [],
      found = [], to_follow = [])
      @uri = uri(url)
      @content_type = content_type
      @upstream_username = upstream_username.empty? ? nil : upstream_username
      @upstream_password = upstream_password.empty? ? nil : upstream_password
      @search = search
      @found = found
      @crawled = crawled
      @to_follow = to_follow
    end
    # rubocop:enable Metrics/ParameterLists

    def uri(url)
      #add a / on the end, as directories require it or else
      #  They will get double slahes on them
      url += '/' unless url.ends_with?('/')
      URI(url)
    end

    def run(resume_point)
      if @content_type == 'docker'
        docker_search
      else
        if @uri.scheme == 'file'
          file_crawl(uri(resume_point))
        elsif %w(http https).include?(@uri.scheme)
          http_crawl(uri(resume_point))
        else
          fail _("Unsupported URL protocol %s.") % @uri.scheme
        end
      end
    end

    private

    def docker_search
      request_params = {
        method: :get,
        headers: { accept: :json },
        url: "#{@uri}v1/search?q=#{@search}"
      }

      request_params[:headers][:user] = @upstream_username unless @upstream_username.empty?
      request_params[:headers][:password] = @upstream_password unless @upstream_password.empty?
      request_params[:proxy] = proxy_uri if proxy

      begin
        results = RestClient::Request.execute(request_params)
        JSON.parse(results)['results'].each do |result|
          @found << result['name']
        end
      rescue
        # Note: v2 endpoint does not support search
        request_params[:url] = "#{@uri}v2/_catalog"
        results = RestClient::Request.execute(request_params)
        JSON.parse(results)['repositories'].each do |result|
          @found << result
        end
      end
      @found.sort!
    end

    def anemone_proxy_details
      details = {}

      if proxy
        details[:proxy_host] = proxy_host
        details[:proxy_port] = proxy_port
        details[:proxy_user] = proxy.username
        details[:proxy_password] = proxy.password
      end

      details
    end

    def http_crawl(resume_point)
      resume_point_uri = URI(resume_point)
      resume_point_uri.user = @upstream_username if @upstream_username
      resume_point_uri.password = @upstream_password if @upstream_password

      Anemone.crawl(resume_point_uri, anemone_proxy_details) do |anemone|
        anemone.focus_crawl do |page|
          @crawled << page.url.path

          page.links.each do |link|
            if link.path.ends_with?('/repodata/')
              page_url = page.url.clone
              page_url.user = nil
              page_url.password = nil
              @found << page_url.to_s
            else
              @to_follow << link.to_s if should_follow?(link.path)
            end
          end
          page.discard_doc! #saves memory, doc not needed
          []
        end
      end
    end

    def file_crawl(resume_point)
      if resume_point.path.ends_with?('/repodata/')
        found_path = Pathname(resume_point.path).parent.to_s
        @found << "file://#{found_path}"
      end
      if resume_point.path == @uri.path
        Dir.glob("#{@uri.path}**/").each { |path| @to_follow << path }
        @to_follow.shift
      end
      @crawled << resume_point.path
    end

    def should_follow?(path)
      #Verify:
      # * link's path starts with the base url
      # * link hasn't already been crawled
      # * link ends with '/' so it should be a directory
      # * link doesn't end with '/Packages/', as this increases
      #       processing time and memory usage considerably
      return path.starts_with?(@uri.path) && !@crawled.include?(path) &&
           path.ends_with?('/') && !path.ends_with?('/Packages/')
    end
  end
end
