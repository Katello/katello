module Katello
  class ContentOverride
    attr_accessor :content_label, :name, :value

    def initialize(content_label, params = {})
      @content_label = content_label
      self.enabled = params[:enabled] if params.key?(:enabled)
    end

    def enabled=(value = nil)
      @name = "enabled"
      @value = value
    end

    def to_entitlement_hash
      ret = {"contentLabel" => @content_label}
      ret["name"] = @name if @name
      ret["value"] = @value if @value
      ret
    end
  end
end
