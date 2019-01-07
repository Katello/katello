module Katello
  class ApplicableContentHelper
    attr_accessor :content_facet, :content_unit_class

    def initialize(content_unit_class, content_facet = nil)
      self.content_facet = content_facet
      self.content_unit_class = content_unit_class
    end

    def import(partial)
      to_add, to_remove = applicable_differences(partial)
      content_facet_association_class.where(:content_facet_id => content_facet.id).delete_all unless partial
      ActiveRecord::Base.transaction do
        insert(to_add) unless to_add.blank?
        remove(to_remove) unless to_remove.blank?
      end
    end

    def installable(env = nil, content_view = nil)
      repos = if env && content_view
                Katello::Repository.in_environment(env).in_content_views([content_view])
              else
                content_facet.bound_repositories.pluck(:id)
              end
      content_facet.send(applicable_units).in_repositories(repos)
    end

    def installable_for_hosts(hosts = nil)
      # Main goal of this query
      # 1) Get me the applicable content units for these set of hosts
      # 2) Now further prune this list. Only include units from repos that have been "enabled" on those hosts.
      #    In other words, prune the list to only include the units in the "bound" repositories signified by
      #    the inner join between ContentFacetRepository and Repository<Unit>

      facet_repos = Katello::ContentFacetRepository.joins(:content_facet => :host).select(:repository_id)
      facet_content_units = content_facet_association_class.joins(:content_facet => :host).select(content_unit_association_id)

      if hosts
        hosts = ::Host.where(id: hosts) if hosts.is_a?(Array)
        facet_repos = facet_repos.merge(hosts).reorder(nil)
        facet_content_units = facet_content_units.merge(hosts).reorder(nil)
      end

      content_unit_class.joins(repository_association_units).
                         where(repository_association_class.table_name => {:repository_id => facet_repos,
                                                                           content_unit_association_id => facet_content_units}).distinct
    end

    private

    def content_units
      content_unit_class.name.demodulize.pluralize.underscore.to_sym
    end

    def applicable_units
      "applicable_#{content_units}".to_sym
    end

    def content_unit_association_id
      "#{content_unit_class.name.demodulize.underscore}_id".to_sym
    end

    def content_type
      content_unit_class.const_get(:CONTENT_TYPE)
    end

    def content_facet_association_class
      # Example: ContentFacetErratum
      self.content_unit_class.content_facet_association_class
    end

    def content_facet_association_units
      content_facet_association_class.name.demodulize.pluralize.underscore.to_sym
    end

    def repository_association_class
      content_unit_class.repository_association_class
    end

    def repository_association_units
      repository_association_class.name.demodulize.pluralize.underscore.to_sym
    end

    def applicable_differences(partial)
      content_uuids = ::Katello::Pulp::Consumer.new(content_facet.uuid).applicable_ids(content_type)
      if partial
        consumer_uuids = content_facet.send(applicable_units).pluck("#{content_unit_class.table_name}.pulp_id")
        to_remove = consumer_uuids - content_uuids
        to_add = content_uuids - consumer_uuids
      else
        to_add = content_uuids
        to_remove = nil
      end
      [to_add, to_remove]
    end

    def insert(pulp_ids)
      applicable_ids = content_unit_class.where(:pulp_id => pulp_ids).pluck(:id)
      unless applicable_ids.empty?
        inserts = applicable_ids.map { |applicable_id| "(#{applicable_id.to_i}, #{content_facet.id.to_i})" }
        sql = "INSERT INTO #{content_facet_association_class.table_name} (#{content_unit_association_id}, content_facet_id) VALUES #{inserts.join(', ')}"
        ActiveRecord::Base.connection.execute(sql)
      end
    end

    def remove(pulp_ids)
      applicable_ids = content_unit_class.where(:pulp_id => pulp_ids).pluck(:id)
      content_facet_association_class.where(:content_facet_id => content_facet.id, content_unit_association_id => applicable_ids).delete_all
    end
  end
end
