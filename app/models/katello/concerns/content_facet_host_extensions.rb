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
        has_many :applicable_errata, :through => :content_facet

        scoped_search :in => :content_view, :on => :name, :complete_value => true, :rename => :content_view
        scoped_search :in => :lifecycle_environment, :on => :name, :complete_value => true, :rename => :lifecycle_environment
        scoped_search :in => :applicable_errata, :on => :errata_id, :rename => :applicable_errata, :complete_value => true, :ext_method => :find_by_applicable_errata

        accepts_nested_attributes_for :content_facet, :reject_if => proc { |attributes| attributes['content_view_id'].blank? && attributes['lifecycle_environment_id'].blank? }
        attr_accessible :content_facet_attributes
      end

      module ClassMethods
        def find_by_applicable_errata(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Erratum.table_name}.errata_id #{operator} ?", value_to_sql(operator, value)])
          hosts = ::Host::Managed.joins(:applicable_errata).where(conditions)
          if hosts.empty?
            { :conditions => "1=0" }
          else
            { :conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.pluck(:id).join(',')})" }
          end
        end
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_view, :lifecycle_environment
end
