module Katello
  module Util
    module Support
      def self.deep_copy(object)
        Marshal.load(Marshal.dump(object))
      end

      def self.time
        a = Time.now
        yield
        Time.now - a
      end

      def self.scrub(params, &block_to_match)
        params.keys.each do |key|
          if params[key].is_a?(Hash)
            scrub(params[key], &block_to_match)
          elsif block_to_match.call(key, params[key])
            params[key] = "[FILTERED]"
          end
        end
        params
      end

      # Helper method to just convert
      # a collection of objects to their
      # string representation (mostly to be used internally)
      def self.stringify(col)
        col.collect { |c| c.to_s }
      end

      # Given a rules hash in the format
      # {<attrib_name>: {<attrib_name> => ...}}
      # the method will match the params attributes to provided
      # rule and return a diff.
      # Here are some of the examples
      # rule -> {:units => [[:name, :version, :min_version, :max_version]]}
      # will match -> {:units => [{:name = > "boo", :version => "2.0"},
      #                 {:name = > "Foo", :min_version => "2.0"}]}
      # rule ->     {:units => [[:id]], :date_range => [:start, :end],
      #                :errata_type => {}, :severity => {}}
      # will match -> {:units => [{:id => 100}],
      #        :date_range => {:start => "05/14/2011"}}
      # Note of caution this merely shows differences in the structure
      # of params vs rules. It doesnt validate anything.
      # Look at SerializedParamsValidator method for its uses.
      def self.diff_hash_params(rule, params)
        params = params.with_indifferent_access
        if rule.is_a?(Array)
          return stringify(params.keys) - stringify(rule)
        end

        rule = rule.with_indifferent_access
        diff_data = rule.keys.collect do |k|
          if params[k]
            if (params[k].is_a?(Array)) && (rule[k].first.is_a?(Array))
              diffs = params[k].collect { |pk| diff_hash_params(rule[k].first, pk) }.flatten
              diffs
            elsif params[k].is_a?(Hash)
              keys = stringify(params[k].keys) - stringify(rule[k])
              if keys.empty?
                nil
              else
                {k => keys}
              end
            end
          end
        end
        diff_data = diff_data.compact.flatten

        return diff_data unless diff_data.nil? || diff_data.empty?
        stringify(params.keys) - stringify(rule.keys)
      end

      # Used for retrying active record transactions when race conditions could cause
      #  RecordNotUnique exceptions
      def self.active_record_retry(retries = 3)
        yield
      rescue ActiveRecord::RecordNotUnique => e
        retries -= 1
        if retries == 0
          raise e
        else
          retry
        end
      end

      # We need this so that we can return
      # empty search results on an invalid query
      # Basically this is a empty array with a total
      # method.
      def self.array_with_total(a = [])
        def a.total
          size
        end
        a
      end
    end
  end
end
