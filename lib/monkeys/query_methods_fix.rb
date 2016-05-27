# fix is from https://github.com/rails/rails/issues/15920
module ActiveRecord
  module QueryMethods
    def build_arel
      arel = Arel::SelectManager.new(table.engine, table)

      build_joins(arel, joins_values.flatten) unless joins_values.empty?

      collapse_wheres(arel, (where_values - ['']).uniq)

      arel.having(*having_values.uniq.reject(&:blank?)) unless having_values.empty?

      arel.take(connection.sanitize_limit(limit_value)) if limit_value
      arel.skip(offset_value.to_i) if offset_value

      arel.group(*group_values.uniq.reject(&:blank?)) unless group_values.empty?

      build_order(arel)

      build_select(arel, select_values.uniq)

      arel.distinct(distinct_value)
      arel.from(build_from) if from_value
      arel.lock(lock_value) if lock_value

      # Reorder bind indexes if joins produced bind values
      bvs = arel.bind_values + bind_values
      arel.ast.grep(Arel::Nodes::BindParam).each_with_index do |bp, i|
        if bvs[i]
          column = bvs[i].first
          bp.replace connection.substitute_at(column, i)
        end
      end

      arel
    end
  end
end
