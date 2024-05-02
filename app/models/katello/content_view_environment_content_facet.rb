module Katello
  class ContentViewEnvironmentContentFacet < Katello::Model
    belongs_to :content_view_environment, :class_name => "::Katello::ContentViewEnvironment", :inverse_of => :content_view_environment_content_facets
    belongs_to :content_facet, :class_name => "::Katello::Host::ContentFacet", :inverse_of => :content_view_environment_content_facets

    validates :content_view_environment_id, presence: true
    validates :content_facet_id, presence: true, unless: :new_record?
    validate :ensure_valid_content_source, if: proc { Setting['validate_host_lce_content_source_coherence'] }

    def ensure_valid_content_source
      source = self.content_facet&.content_source
      return if source&.pulp_primary? # pulp_primary smart proxy always has all content
      env = self.content_view_environment&.environment
      hostname = self.content_facet&.host&.name
      return unless [source, env].all? { |x| x.present? }
      unless source.lifecycle_environments.include?(env)
        error_msg = _("Host %{hostname}: Cannot add content view environment to content facet. The host's content source '%{content_source}' does not sync lifecycle environment '%{lce}'.") % { hostname: hostname, content_source: source.name, lce: env.name }
        Rails.logger.warn error_msg
        errors.add(:base, error_msg)
      end
    end
  end
end
