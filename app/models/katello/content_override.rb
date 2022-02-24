module Katello
  class ContentOverride
    attr_accessor :content_label, :name, :value

    def initialize(content_label, params = {})
      @content_label = content_label
      if params.key?(:enabled)
        self.enabled = params[:enabled]
      else
        @name = params[:name]
        @value = params[:value]
      end
    end

    def enabled=(value = nil)
      @name = "enabled"
      @value = value
    end

    def computed_value
      return if self.value.nil?

      if self.name == "enabled"
        ::Foreman::Cast.to_bool(self.value)
      else
        self.value
      end
    end

    def to_entitlement_hash
      ret = {"contentLabel" => @content_label}
      ret["name"] = @name if @name
      ret["value"] = @value if @value
      ret.with_indifferent_access
    end

    def self.from_entitlement_hash(entitlement_hash)
      ent_hash =  entitlement_hash.with_indifferent_access
      override = ContentOverride.new(ent_hash["contentLabel"])
      override.name = ent_hash["name"]
      override.value = ent_hash["value"]
      override
    end

    def ==(other)
      if self.class == other.class
        self.content_label == other.content_label &&
          self.name == other.name &&
          self.value == other.value
      else
        super
      end
    end

    def to_hash
      {"content_label" => @content_label, "name" => @name, "value" => @value}
    end

    def self.fetch(params)
      if params.is_a?(ContentOverride)
        params
      else
        ContentOverride.new(params["content_label"], :name => params["name"], :value => params["value"])
      end
    end
  end
end
