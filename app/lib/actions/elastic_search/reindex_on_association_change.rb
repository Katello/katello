module Actions
  module ElasticSearch
    class ReindexOnAssociationChange < ElasticSearch::Abstract
      def plan(record)
        plan_self(id: record.id,
                  class_name: record.class.name)
      end

      input_format do
        param :id
        param :class_name
      end

      def finalize
        model_class = input[:class_name].constantize
        record      = model_class.find_by_id(input[:id])

        if record
          record.update_index if record.respond_to? :update_index
          record.class.index.refresh if record.class.respond_to? :index
        end
      end
    end
  end
end
