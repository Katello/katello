#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  class RepoDiscovery
    attr_reader :found

    def initialize(url, options = {})
      #add a / on the end, as directories require it or else
      #  They will get double slahes on them
      url += '/' unless url.ends_with?('/')
      @uri = URI(url)
      @found = []
      @crawled = []
      @options = options
    end

    def run(found_lambda, continue_lambda)
      if @uri.scheme == 'file'
        file_crawl(found_lambda, continue_lambda)
      elsif %w(http https).include?(@uri.scheme)
        http_crawl(found_lambda, continue_lambda)
      else
        fail _("Unsupported URL protocol %s.")  % @uri.scheme
      end
    end

    private

    def http_crawl(found_lambda, continue_lambda)
      Anemone.crawl(@uri, @options) do |anemone|
        anemone.focus_crawl do |page|
          return false unless continue_lambda.call
          @crawled << page.url.path

          to_follow = []
          page.links.each do |link|
            if link.path.ends_with?('/repodata/')
              @found << page.url.to_s
              found_lambda.call(page.url.to_s)
            else
              to_follow << link if should_follow?(link.path)
            end
          end
          page.discard_doc! #saves memory, doc not needed
          to_follow
        end
      end
      @found
    end

    def file_crawl(found_lambda, continue_lambda)
      directories = Dir.glob("#{@uri.path}**/")
      directories.each do |dir|
        return false unless continue_lambda.call

        if dir.ends_with?('/repodata/')
          found_path = Pathname(dir).parent.to_s
          @found << "file://#{found_path}"
          found_lambda.call("file://#{found_path}")
        end
      end
      @found
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
