module Katello
  module Pulp3
    class PagedResults
      def self.fetch_paged_results(pulp3_api, method, opts = {})
        results_pending = true
        page_opts = { "page" => 1 }
        page_opts.merge! opts
        results = []
        while results_pending
          page_opts = page_opts.with_indifferent_access
          response = pulp3_api.send(method, page_opts)
          results += response.results
          if response.as_json["next"]
            page_opts.merge!(:page => (page_opts[:page] + 1))
          else
            results_pending = false
          end
        end
        results
      end
    end
  end
end
