module Katello
  class FileDiscovery < RepoDiscovery
    attr_reader :found, :crawled, :to_follow
    def initialize(url, crawled = [], found = [], to_follow = [], _upstream_credentials_and_search = {})
      @uri = uri(url)
      @found = found
      @crawled = crawled
      @to_follow = to_follow
    end

    def run(resume_point)
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
  end
end
