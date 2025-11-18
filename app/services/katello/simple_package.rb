module Katello
  class SimplePackage
    attr_accessor :vendor, :arch, :epoch, :version, :release, :name, :persistence

    def initialize(params = {})
      params.each_pair { |k, v| instance_variable_set("@#{k}", v) unless v.nil? }
    end

    def nvra
      "#{@name}-#{@version}-#{@release}.#{@arch}"
    end

    def nvrea
      if epoch.nil? || epoch.to_s == "0"
        nvra
      else
        "#{@name}-#{@epoch}:#{@version}-#{@release}.#{@arch}"
      end
    end
  end
end
