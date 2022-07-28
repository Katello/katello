module Katello
  class SmartProxyAlternateContentSource < Katello::Model
    audited
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    self.table_name = :katello_smart_proxy_alternate_content_sources
    belongs_to :smart_proxy, :inverse_of => :smart_proxy_alternate_content_sources, :class_name => 'SmartProxy'
    belongs_to :alternate_content_source, :inverse_of => :smart_proxy_alternate_content_sources, :class_name => 'Katello::AlternateContentSource'
    belongs_to :repository, :inverse_of => :smart_proxy_alternate_content_sources, :class_name => 'Katello::Repository'

    def backend_service
      @service ||= ::Katello::Pulp3::AlternateContentSource.new(alternate_content_source, smart_proxy, repository)
    end
  end
end
