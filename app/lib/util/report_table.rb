#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.



module Util
  class ReportTable

    attr_accessor :transform, :column_names, :data, :renamed_columns, :column_hash

    def initialize(params)
      self.transform = params[:transforms]
      self.column_names = params[:column_names] || []#retained for ordering
      self.data = params[:data]
      self.renamed_columns = {}
      self.column_hash = {}
      column_names.each{|name| column_hash[name] = {:name=>name}}
    end

    def rename_column(original, new)
      column_hash[original][:name] = new
    end

    def as(type)
      if type == :csv
        as_csv(transform_data())
      elsif type == :text
        as_text(transform_data())
      end
    end

    private

    def transform_data
      record_data = data.collect do |d|
        OpenStruct.new(d.slice(*self.column_names))
      end
      record_data.each{|d| self.transform.call(d)}
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
      text += "|#{column_names.collect{|name| pad(column_hash[name][:name], column_hash[name][:size])}.join("|")}|\n"
      text += text_separator(total)

      transformed_data.each do |row|
        text += "|#{column_names.collect{|name| pad(row.send(name), column_hash[name][:size])}.join("|")}|\n"
        text += text_separator(total)
      end

      text
    end

    def text_separator(size)
     "+" +  ("-" * size) + "+\n"
    end

    def pad(string, max_size)
      new_spaces = max_size - string.size
      left = new_spaces/2.to_i
      right = new_spaces - left
      debugger if left < 0 || right < 0
      (" "*left) + string + (" "*right)
    end

    def as_csv(transformed_data)
      csv = ""
      csv += column_names.collect{|name| column_hash[name][:name]}.join(",")
      csv += "\n"
      transformed_data.each do |item|
        csv += column_names.collect{|name| item.send(name)}.join(',')
        csv += "\n"
      end
      csv
    end
  end
end
