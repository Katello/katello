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
        }.freeze

        TRACE_STATUS_MAP = {
          :reboot_needed => Katello::TraceStatus::REQUIRE_REBOOT,
          :process_restart_needed => Katello::TraceStatus::REQUIRE_PROCESS_RESTART,
          :updated => Katello::TraceStatus::UP_TO_DATE
        }.freeze

        has_one :errata_status_object, :class_name => 'Katello::ErrataStatus', :foreign_key => 'host_id'
        scoped_search :on => :status, :relation => :errata_status_object, :rename => :errata_status,
                     :complete_value => ERRATA_STATUS_MAP
        has_one :trace_status_object, :class_name => 'Katello::TraceStatus', :foreign_key => 'host_id'
        scoped_search :on => :status, :relation => :trace_status_object, :rename => :trace_status,
                     :complete_value => TRACE_STATUS_MAP

        #associations for simpler scoped searches
        has_one :content_view, :through => :content_facet
        has_one :lifecycle_environment, :through => :content_facet
        has_one :content_source, :through => :content_facet
        has_many :applicable_errata, :through => :content_facet
        has_many :applicable_rpms, :through => :content_facet

        scoped_search :relation => :content_view, :on => :name, :complete_value => true, :rename => :content_view
        scoped_search :relation => :content_facet, :on => :content_view_id, :rename => :content_view_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
        scoped_search :relation => :lifecycle_environment, :on => :name, :complete_value => true, :rename => :lifecycle_environment
        scoped_search :relation => :content_facet, :on => :lifecycle_environment_id, :rename => :lifecycle_environment_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
        scoped_search :relation => :applicable_errata, :on => :errata_id, :rename => :applicable_errata, :complete_value => true, :ext_method => :find_by_applicable_errata, :only_explicit => true
        scoped_search :relation => :applicable_errata, :on => :errata_id, :rename => :installable_errata, :complete_value => true, :ext_method => :find_by_installable_errata, :only_explicit => true
        scoped_search :relation => :applicable_rpms, :on => :nvra, :rename => :applicable_rpms, :complete_value => true, :ext_method => :find_by_applicable_rpms, :only_explicit => true
        scoped_search :relation => :applicable_rpms, :on => :nvra, :rename => :upgradable_rpms, :complete_value => true, :ext_method => :find_by_installable_rpms, :only_explicit => true
        scoped_search :relation => :content_source, :on => :name, :complete_value => true, :rename => :content_source

        # preserve options set by facets framework, but add new :reject_if statement
        accepts_nested_attributes_for(
          :content_facet,
          self.nested_attributes_options[:content_facet].merge(
            :reject_if => :content_facet_ignore_update?)
        )

        def content_facet_ignore_update?(attributes)
          self.content_facet.blank? && attributes.blank?
        end
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

        def find_by_installable_errata(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Erratum.table_name}.errata_id #{operator} ?", value_to_sql(operator, value)])
          facets = Katello::Host::ContentFacet.joins_installable_errata.where(conditions)
          if facets.empty?
            { :conditions => "1=0" }
          else
            { :conditions => "#{::Host::Managed.table_name}.id IN (#{facets.pluck(:host_id).join(',')})" }
          end
        end

        def find_by_applicable_rpms(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Rpm.table_name}.nvra #{operator} ?", value_to_sql(operator, value)])
          hosts = ::Host::Managed.joins(:applicable_rpms).where(conditions)
          if hosts.empty?
            { :conditions => "1=0" }
          else
            { :conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.pluck(:id).join(',')})" }
          end
        end

        def find_by_installable_rpms(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Rpm.table_name}.nvra #{operator} ?", value_to_sql(operator, value)])
          facets = Katello::Host::ContentFacet.joins_installable_rpms.where(conditions)
          if facets.empty?
            { :conditions => "1=0" }
          else
            { :conditions => "#{::Host::Managed.table_name}.id IN (#{facets.pluck(:host_id).join(',')})" }
          end
        end

        def in_content_view_environment(content_view: nil, lifecycle_environment: nil)
          relation = self.joins(:content_facet)
          relation = relation.where("#{::Katello::Host::ContentFacet.table_name}.content_view_id" => content_view) if content_view
          relation = relation.where("#{::Katello::Host::ContentFacet.table_name}.lifecycle_environment_id" => lifecycle_environment) if lifecycle_environment
          relation
        end

        def in_environment(lifecycle_environment)
          in_content_view_environment(:lifecycle_environment => lifecycle_environment)
        end
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_view, :lifecycle_environment, :content_source
end
