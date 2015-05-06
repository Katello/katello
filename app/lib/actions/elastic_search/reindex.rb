module Actions
  module ElasticSearch
    class Reindex < ElasticSearch::Abstract
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
          record.update_index
        else
          model_class.index.remove(type: input[:class_name], id: input[:id])
        end
      end
    end
  end
end
