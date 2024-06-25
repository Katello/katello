require 'csv'

module Katello
  module Util
    class ReportTable
      attr_accessor :transform, :column_names, :data, :renamed_columns, :column_hash

      def initialize(params)
        self.transform = params[:transforms]
        self.column_names = params.fetch(:column_names, []) #retained for ordering
        self.data = params[:data]
        self.renamed_columns = {}
        self.column_hash = {}
        column_names.each { |name| column_hash[name] = {:name => name} }
      end

      def rename_column(original, new)
        column_hash[original][:name] = new
      end

      def as(type)
        case type
        when :csv
          as_csv(transform_data)
        when :text
          as_text(transform_data)
        end
      end

      private

      def transform_data
        record_data = data.collect do |d|
          OpenStruct.new(d.slice(*self.column_names))
        end
        record_data.each { |d| self.transform.call(d) }
        record_data
      end

      def calculate_column_size(transformed_data)
        total = 0
        column_names.each do |name|
          max_size = column_hash[name][:name].size
          transformed_data.each do |row|
            text_size = row.send(name).to_s.size
            max_size = text_size if max_size < text_size
          end
          column_hash[name][:size] = (max_size + 2)
          total += (max_size + 2)
        end
        total
      end

      def as_text(transformed_data)
        text = ""
        total = calculate_column_size(transformed_data) + column_names.size - 1
        text += text_separator(total)
        text += "|#{column_names.collect { |name| pad(column_hash[name][:name], column_hash[name][:size]) }.join("|")}|\n"
        text += text_separator(total)

        transformed_data.each do |row|
          text += "|#{column_names.collect { |name| pad(row.send(name), column_hash[name][:size]) }.join("|")}|\n"
          text += text_separator(total)
        end

        text
      end

      def text_separator(size)
        "+#{'-' * size}+\n"
      end

      def pad(string, max_size)
        new_spaces = max_size - string.size
        left = new_spaces / 2.to_i
        right = new_spaces - left
        (" " * left) + string + (" " * right)
      end

      def as_csv(transformed_data)
        CSV.generate do |csv|
          csv << column_names.collect { |name| column_hash[name][:name] }
          transformed_data.each do |item|
            csv << column_names.collect { |name| item.send(name) }
          end
        end
      end
    end
  end
end
