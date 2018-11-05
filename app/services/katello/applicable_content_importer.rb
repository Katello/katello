module Katello
  class ApplicableContentImporter
    attr_accessor :content_facet, :content_unit_class

    def initialize(content_facet, content_unit_class)
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

    private

    def applicable_units
      "applicable_#{content_unit_class.name.demodulize.pluralize.underscore}"
    end

    def content_unit_association_id
      "#{content_unit_class.name.demodulize.underscore}_id"
    end

    def content_type
      content_unit_class.const_get(:CONTENT_TYPE)
    end

    def content_facet_association_class
      self.content_unit_class.content_facet_association_class
    end

    def applicable_differences(partial)
      content_uuids = ::Katello::Pulp::Consumer.new(content_facet.uuid).applicable_ids(content_type)
      if partial
        consumer_uuids = content_facet.send(applicable_units).pluck("#{content_unit_class.table_name}.uuid")
        to_remove = consumer_uuids - content_uuids
        to_add = content_uuids - consumer_uuids
      else
        to_add = content_uuids
        to_remove = nil
      end
      [to_add, to_remove]
    end

    def insert(uuids)
      applicable_ids = content_unit_class.where(:uuid => uuids).pluck(:id)
      unless applicable_ids.empty?
        inserts = applicable_ids.map { |applicable_id| "(#{applicable_id.to_i}, #{content_facet.id.to_i})" }
        sql = "INSERT INTO #{content_facet_association_class.table_name} (#{content_unit_association_id}, content_facet_id) VALUES #{inserts.join(', ')}"
        ActiveRecord::Base.connection.execute(sql)
      end
    end

    def remove(uuids)
      applicable_ids = content_unit_class.where(:uuid => uuids).pluck(:id)
      content_facet_association_class.where(:content_facet_id => content_facet.id, content_unit_association_id => applicable_ids).delete_all
    end
  end
end
