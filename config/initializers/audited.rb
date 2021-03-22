class KatelloAudit < Audited::Audit
  def self.name
    if super.start_with?("::")
      super
    else
      "::#{super}"
    end
  end
end

Audited.config do |config|
  config.audit_class = KatelloAudit
end
