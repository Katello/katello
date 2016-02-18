module Katello
  module Concerns
    module ContentFacetHostExtensions
      extend ActiveSupport::Concern

      included do
        ERRATA_STATUS_MAP = {
          :security_needed => Katello::ErrataStatus::NEEDED_SECURITY_ERRATA,
          :errata_needed => Katello::ErrataStatus::NEEDED_ERRATA,
          :updated => Katello::ErrataStatus::UP_TO_DATE,
          :unknown => Katello::ErrataStatus::UNKNOWN
        }

        has_one :content_facet, :class_name => '::Katello::Host::ContentFacet', :foreign_key => :host_id, :inverse_of => :host, :dependent =>  :destroy

        has_one :errata_status_object, :class_name => 'Katello::ErrataStatus', :foreign_key => 'host_id'
        scoped_search :on => :status, :in => :errata_status_object, :rename => :errata_status,
                     :complete_value => ERRATA_STATUS_MAP

        #associations for simpler scoped searches
        has_one :content_view, :through => :content_facet
        has_one :lifecycle_environment, :through => :content_facet

        scoped_search :in => :content_view, :on => :name, :complete_value => true, :rename => :content_view
        scoped_search :in => :lifecycle_environment, :on => :name, :complete_value => true, :rename => :lifecycle_environment

        accepts_nested_attributes_for :content_facet, :reject_if => proc { |attributes| attributes['content_view_id'].blank? && attributes['lifecycle_environment_id'].blank? }
        attr_accessible :content_facet_attributes
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_view, :lifecycle_environment
end
