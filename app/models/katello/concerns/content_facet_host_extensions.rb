module Katello
  module Concerns
    module ContentFacetHostExtensions
      extend ActiveSupport::Concern

      included do
        ERRATA_STATUS_MAP = {
          :security_needed => Katello::ErrataStatus::NEEDED_SECURITY_ERRATA,
          :errata_needed => Katello::ErrataStatus::NEEDED_ERRATA,
          :updated => Katello::ErrataStatus::UP_TO_DATE,
          :unknown => Katello::ErrataStatus::UNKNOWN,
        }.freeze

        TRACE_STATUS_MAP = {
          :reboot_needed => Katello::TraceStatus::REQUIRE_REBOOT,
          :process_restart_needed => Katello::TraceStatus::REQUIRE_PROCESS_RESTART,
          :updated => Katello::TraceStatus::UP_TO_DATE,
        }.freeze

        has_one :errata_status_object, :class_name => 'Katello::ErrataStatus', :foreign_key => 'host_id', :dependent => :destroy
        scoped_search :on => :status, :relation => :errata_status_object, :rename => :errata_status,
                     :complete_value => ERRATA_STATUS_MAP
        has_one :trace_status_object, :class_name => 'Katello::TraceStatus', :foreign_key => 'host_id', :dependent => :destroy
        scoped_search :on => :status, :relation => :trace_status_object, :rename => :trace_status,
                     :complete_value => TRACE_STATUS_MAP

        #associations for simpler scoped searches
        has_many :content_view_environment_content_facets, through: :content_facet, class_name: 'Katello::ContentViewEnvironmentContentFacet'
        has_many :content_view_environments, through: :content_view_environment_content_facets
        has_many :content_views, through: :content_view_environments
        has_many :lifecycle_environments, through: :content_view_environments

        has_one :content_source, :through => :content_facet
        has_many :content_facet_errata, :through => :content_facet, :class_name => 'Katello::ContentFacetErratum'
        has_many :applicable_errata, :through => :content_facet_errata, :source => :erratum
        has_many :applicable_debs, :through => :content_facet
        has_many :applicable_rpms, :through => :content_facet
        has_many :applicable_module_streams, :through => :content_facet
        has_many :bound_repositories, :through => :content_facet
        has_many :bound_root_repositories, :through => :content_facet
        has_many :bound_content, :through => :content_facet

        scoped_search :relation => :content_views, :on => :name, :complete_value => true, :rename => :content_views
        scoped_search :relation => :lifecycle_environments, :on => :name, :complete_value => true, :rename => :lifecycle_environments
        scoped_search :relation => :applicable_errata, :on => :errata_id, :rename => :applicable_errata, :complete_value => true, :ext_method => :find_by_applicable_errata, :only_explicit => true
        scoped_search :relation => :applicable_errata, :on => :errata_id, :rename => :installable_errata, :complete_value => true, :ext_method => :find_by_installable_errata, :only_explicit => true
        scoped_search :relation => :applicable_errata, :on => :issued, :rename => :applicable_errata_issued, :complete_value => true, :only_explicit => true
        scoped_search :relation => :applicable_debs, :on => :nav, :rename => :applicable_debs, :complete_value => true, :ext_method => :find_by_applicable_debs, :only_explicit => true, :operators => ['=']
        scoped_search :relation => :applicable_debs, :on => :nav, :rename => :upgradable_debs, :complete_value => true, :ext_method => :find_by_installable_debs, :only_explicit => true, :operators => ['=']
        scoped_search :relation => :applicable_rpms, :on => :nvra, :rename => :applicable_rpms, :complete_value => true, :ext_method => :find_by_applicable_rpms, :only_explicit => true
        scoped_search :relation => :applicable_rpms, :on => :nvra, :rename => :upgradable_rpms, :complete_value => true, :ext_method => :find_by_installable_rpms, :only_explicit => true
        scoped_search :relation => :content_source, :on => :name, :complete_value => true, :rename => :content_source
        scoped_search :relation => :bound_root_repositories, :on => :name, :rename => :repository, :complete_value => true, :ext_method => :find_by_repository_name, :only_explicit => true
        scoped_search :relation => :bound_content, :on => :label, :rename => :repository_content_label, :complete_value => true, :ext_method => :find_by_repository_content_label, :only_explicit => true

        scoped_search relation: :content_facet, on: :bootc_booted_image, complete_value: true, only_explicit: true
        scoped_search relation: :content_facet, on: :bootc_booted_digest, complete_value: true, only_explicit: true
        scoped_search relation: :content_facet, on: :bootc_available_image, complete_value: true, only_explicit: true
        scoped_search relation: :content_facet, on: :bootc_available_digest, complete_value: true, only_explicit: true
        scoped_search relation: :content_facet, on: :bootc_staged_image, complete_value: true, only_explicit: true
        scoped_search relation: :content_facet, on: :bootc_staged_digest, complete_value: true, only_explicit: true
        scoped_search relation: :content_facet, on: :bootc_rollback_image, complete_value: true, only_explicit: true
        scoped_search relation: :content_facet, on: :bootc_rollback_digest, complete_value: true, only_explicit: true
        scoped_search relation: :content_facet, on: :bootc_booted_image, rename: :image_mode, only_explicit: true, ext_method: :find_by_image_mode,
                      operators: ['='], complete_value: { true: true, false: false}

        # preserve options set by facets framework, but add new :reject_if statement
        accepts_nested_attributes_for(
          :content_facet,
          self.nested_attributes_options[:content_facet].merge(
            :reject_if => :content_facet_ignore_update?)
        )

        def content_facet_ignore_update?(attributes)
          self.content_facet.blank? && (
            attributes.values.all?(&:blank?) ||
            attributes['content_view_id'].blank? ||
            attributes['lifecycle_environment_id'].blank?
          )
        end

        apipie :class do
          property :content_views, 'ContentView', desc: 'Returns content views associated with the host'
          property :lifecycle_environments, 'KTEnvironment', desc: 'Returns lifecycle environment objects associated with the host'
          property :content_source, 'SmartProxy', desc: 'Returns Smart Proxy object as the content source for the host'
          property :applicable_errata, array_of: 'Erratum', desc: 'Returns errata applicable to the host'
        end
      end

      module ClassMethods
        def find_by_image_mode(_key, _operator, value)
          # operator is always '='
          state = ::Foreman::Cast.to_bool(value)
          if state
            hosts = ::Host::Managed.joins(:content_facet).select(:id).where.not("#{::Katello::Host::ContentFacet.table_name}.bootc_booted_image" => nil)
          else
            hosts = ::Host::Managed.joins(:content_facet).select(:id).where("#{::Katello::Host::ContentFacet.table_name}.bootc_booted_image" => nil)
          end
          { :conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.to_sql})" }
        end

        def find_by_applicable_errata(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Erratum.table_name}.errata_id #{operator} ?", value_to_sql(operator, value)])
          hosts = ::Host::Managed.joins(:applicable_errata).select(:id).where(conditions)
          { :conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.to_sql})" }
        end

        def find_by_installable_errata(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Erratum.table_name}.errata_id #{operator} ?", value_to_sql(operator, value)])
          facets = Katello::Host::ContentFacet.joins_installable_errata.select(:host_id).where(conditions)
          { :conditions => "#{::Host::Managed.table_name}.id IN (#{facets.to_sql})" }
        end

        def find_by_applicable_debs(_key, operator, value)
          hosts = find_by_debs(::Host::Managed.joins(:applicable_debs), operator, value)
          if hosts.empty?
            { :conditions => "1=0" }
          else
            { :conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.pluck(:id).join(',')})" }
          end
        end

        def find_by_installable_debs(_key, operator, value)
          facets = find_by_debs(Katello::Host::ContentFacet.joins_installable_debs, operator, value)
          if facets.empty?
            { :conditions => "1=0" }
          else
            { :conditions => "#{::Host::Managed.table_name}.id IN (#{facets.pluck(:host_id).join(',')})" }
          end
        end

        def find_by_applicable_rpms(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Rpm.table_name}.nvra #{operator} ?", value_to_sql(operator, value)])
          hosts = ::Host::Managed.joins(:applicable_rpms).select(:id).where(conditions)
          { :conditions => "#{::Host::Managed.table_name}.id IN (#{hosts.to_sql})" }
        end

        def find_by_installable_rpms(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Rpm.table_name}.nvra #{operator} ?", value_to_sql(operator, value)])
          facets = Katello::Host::ContentFacet.joins_installable_rpms.select(:host_id).where(conditions)
          { :conditions => "#{::Host::Managed.table_name}.id IN (#{facets.to_sql})" }
        end

        def find_by_repository_content_label(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::Content.table_name}.label #{operator} ?", value_to_sql(operator, value)])
          facets = Katello::Host::ContentFacet.joins_repositories.select(:host_id).where(conditions)
          { :conditions => "#{::Host::Managed.table_name}.id IN (#{facets.to_sql})" }
        end

        def find_by_repository_name(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::RootRepository.table_name}.name #{operator} ?", value_to_sql(operator, value)])
          facets = Katello::Host::ContentFacet.joins_repositories.select(:host_id).where(conditions)
          { :conditions => "#{::Host::Managed.table_name}.id IN (#{facets.to_sql})" }
        end

        def in_content_view_environments(content_views: nil, lifecycle_environments: nil)
          relation = self.joins(:content_facet => {:content_view_environment_content_facets => :content_view_environment })
          relation = relation.where("#{::Katello::ContentViewEnvironment.table_name}.content_view_id" => content_views) if content_views
          relation = relation.where("#{::Katello::ContentViewEnvironment.table_name}.environment_id" => lifecycle_environments) if lifecycle_environments
          relation
        end

        def in_environments(lifecycle_environments)
          in_content_view_environments(:lifecycle_environments => lifecycle_environments)
        end

        def in_content_view_environment(content_view: nil, lifecycle_environment: nil)
          Rails.logger.warn "DEPRECATION WARNING: in_content_view_environment is deprecated and will be removed in Katello 4.8.  Please use in_content_view_environments instead."
          in_content_view_environments(:content_views => content_view, :lifecycle_environments => lifecycle_environment)
        end

        def in_environment(lifecycle_environment)
          Rails.logger.warn "DEPRECATION WARNING: in_environment is deprecated and will be removed in Katello 4.9.  Please use in_environments instead."
          in_environments(lifecycle_environment)
        end

        private

        def find_by_debs(base, operator, value)
          table = Katello::Deb.table_name

          name, architecture, version = Katello::Deb.split_nav(value)
          if name.nil?
            return []
          end

          res = base.where(sanitize_sql_for_conditions(["#{table}.name #{operator} ?", value_to_sql(operator, name)]))

          res = res.where(sanitize_sql_for_conditions(["#{table}.architecture #{operator} ?", value_to_sql(operator, architecture)])) unless architecture.nil?

          res = res.where(sanitize_sql_for_conditions(["#{table}.version #{operator} ?", value_to_sql(operator, version)])) unless version.nil?

          res
        end
      end
    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_source, :applicable_errata
end
