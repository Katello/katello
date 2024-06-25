module Katello
  class HashUtil
    def null_safe_get(hash, default, params)
      # Base case .. if we are down to the last param
      # lets actually try and find the value
      if params.size == 1
        begin
          # If we got back null lets assign the default
          return hash[params[0]] || default
        rescue
          # If we errored out trying to fetch the value we return
          # default value.
          return default
        end
      end
      subhash = hash[params.first]
      # If we don't have a subhash don't try and recurse down
      if !subhash.nil? && !subhash.empty?
        self.null_safe_get(subhash, default, params[1..])
      else
        default
      end
    end
  end
end
