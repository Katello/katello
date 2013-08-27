#This allows us to accept "JSON" that is malformed
# and is empty string ("") that subscription-manager-1.1.23-1.el6.x86_64
# will from time to time, send to katello
module MultiJson
  class<< self
    alias_method :old_aliased_load, :load

    def load(string, options = {})
      string = string.read if string.respond_to?(:read)
      string = "{}" if string == '""'
      old_aliased_load(string, options)
    end
  end
end
