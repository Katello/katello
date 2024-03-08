require 'uri'
require 'spidr'

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
          #http_crawl(resume_point)
          spidr_crawl(resume_point)
        else
          fail _("Unsupported URL protocol %s.") % @uri.scheme
        end
      end
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
        url: "#{@uri}v1/search?q=#{@search}"
      }

      request_params[:user] = @upstream_username unless @upstream_username.empty?
      request_params[:password] = @upstream_password unless @upstream_password.empty?
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

    def spidr_crawl(url)
      user = @upstream_username if @upstream_username
      password = @upstream_password if @upstream_password
      #Spidr crawl the url over every url and add urls with repodata to found
      Spidr.site(url, proxy: spidr_proxy_details) do |spider|
        spider.authorized.add(url, user, password)
        spider.every_url do |url|
          if @found.include?(url.to_s.split('repodata/').first)
            puts ">>> Skipping #{url.to_s}"
            spider.skip_link!
          end
          if url.to_s.include? 'repodata/'
            @found << url.to_s.split('repodata/').first
            puts ">>> Found #{url.to_s.split('repodata/').first}"
          end
        end
      end
    end

    def spidr_crawl_url(url)
      Spidr.site(url) do |spider|
        spider.every_page do |page|
          next if page.url.to_s.include?('bigzoo') || page.url.to_s.include?('ostree') || page.url.to_s.include?('?')
          page.each_url do |crawl_link|
            break if @crawled.include?(crawl_link.to_s) or crawl_link.to_s.include?('bigzoo') or crawl_link.to_s.include?('ostree')
              @crawled << crawl_link.to_s
              puts "Processing page > #{page.url.to_s}"
              puts "Processing link > #{crawl_link.to_s}"
              if(crawl_link.to_s.include? 'repodata/')
                @found << (crawl_link).to_s
                  puts ">>> Found #{crawl_link.to_s}"
                  break
              elsif !crawl_link.to_s.include?("http") && should_follow?((crawl_link).to_s)
                puts ">>> Following #{crawl_link.to_s}"
                @to_follow << (crawl_link).to_s
              end
          end
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
