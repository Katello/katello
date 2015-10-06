module Katello
  class Glue::Pulp::SimplePackage
    # {"epoch", "name", "arch", "version", "vendor", "release"}
    attr_accessor :vendor, :arch, :epoch, :version, :release, :name

    def initialize(params = {})
      params.each_pair { |k, v| instance_variable_set("@#{k}", v) unless v.nil? }
    end

    def nvra
      nvrea
    end

    def nvrea
      "#{@name}-#{@version}-#{@release}.#{@arch}"
    end
  end
end
