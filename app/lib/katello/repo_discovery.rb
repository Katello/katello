module Katello
  class RepoDiscovery
    attr_reader :found, :crawled, :to_follow

    def initialize(url, proxy = {}, crawled = [], found = [], to_follow = [])
      #add a / on the end, as directories require it or else
      #  They will get double slahes on them
      @uri = uri(url)
      @found = found
      @crawled = crawled
      @to_follow = to_follow
      @proxy = proxy
    end

    def uri(url)
      url += '/' unless url.ends_with?('/')
      URI(url)
    end

    def run(resume_point)
      if @uri.scheme == 'file'
        file_crawl(uri(resume_point))
      elsif %w(http https).include?(@uri.scheme)
        http_crawl(uri(resume_point))
      else
        fail _("Unsupported URL protocol %s.")  % @uri.scheme
      end
    end

    private

    def http_crawl(resume_point)
      Anemone.crawl(resume_point, @proxy) do |anemone|
        anemone.focus_crawl do |page|
          @crawled << page.url.path

          page.links.each do |link|
            if link.path.ends_with?('/repodata/')
              @found << page.url.to_s
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
