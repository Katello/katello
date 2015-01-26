# Patch from https://github.com/rails/rails/pull/8862

module ActionDispatch
  Request.class_eval do
    # Remove nils from the params hash
    def deep_munge(hash)
      hash ||= {}
      hash.each do |k, v|
        case v
        when Array
          if v.size > 0 && v.all?(&:nil?)
            hash[k] = nil
            next
          end
          v.grep(Hash) { |x| deep_munge(x) }
          v.compact!
        when Hash
          deep_munge(v)
        end
      end

      hash
    end
  end
end
