require 'katello_test_helper'

module Katello
  describe 'associations' do
    def source_code_location(model, association)
      path     = "#{Katello::Engine.root}/app/models/katello/#{model.name.underscore}.rb"
      location = if File.exist? path
                   content     = File.read path
                   line_number = content.lines.find_index do |line|
                     line =~ /(belongs_to|has_(one|many)) +#{association.name.inspect}/
                   end
                   "#{path}:#{line_number.try :+, 1}"
                 else
                   '<unknown>'
                 end
      return "\nin #{location}"
    end

    def ignorable_foreign_keys
      {
        "katello_task_statuses" => ["task_owner_id"],
        "katello_content_view_erratum_filter_rules" => ["errata_id"],
        "katello_repositories" => ["content_id"]
      }
    end

    Katello::Model.subclasses.each do |model|
      next unless model.table_name&.starts_with?('katello_')
      next if model.ancestors.include? Facets::Base
      next if model.ancestors.include? Facets::HostgroupFacet

      describe model do
        model.reflect_on_all_associations(:belongs_to).each do |association|
          describe "belongs_to: #{association.name.inspect}" do
            unless association.options.key? :polymorphic
              it('has :inverse_of option') do
                unless association.class_name.start_with?("ForemanTasks::")
                  assert(association.options.key?(:inverse_of),
                         "inverse association cannot be found without the option set #{source_code_location(model, association)}")
                end
              end

              it("inverse association exists") do
                unless association.class_name.start_with?("ForemanTasks::")
                  assert(association.inverse_of,
                         "the inverse association which would take care of deletion avoiding FK errors could not be found  #{source_code_location(model, association)}")
                end
              end

              it('is using correct foreign_key') do
                unless association.class_name.start_with?("ForemanTasks::")
                  assert_includes model.column_names, fk = association.foreign_key.to_s,
                         "unknown foreign_key #{fk}  #{source_code_location(model, association)}"
                end
              end

              it "foreign_key_id actually exists for the table" do
                unless association.class_name.start_with?("ForemanTasks::") || ignorable_foreign_keys.fetch(model.table_name, []).include?(association.foreign_key.to_s)
                  conn = ActiveRecord::Base.connection
                  fk_columns = conn.foreign_keys(model.table_name).map do |col|
                    col.options[:column]
                  end
                  fk_columns.flatten!
                  fk_columns.uniq!
                  msg = "Foreign key constraint not defined for #{model.table_name}.#{association.foreign_key}"
                  assert_includes fk_columns, association.foreign_key.to_s, msg
                end
              end
            end
          end
        end

        associations = model.reflect_on_all_associations(:has_many) + model.reflect_on_all_associations(:has_one)
        associations.each do |association|
          next if association.options.key?(:through)
          conditioned = association.options.key? :conditions
          describe "has_(many|one): #{association.name.inspect} #{'with conditions' if conditioned}" do
            it("#{conditioned ? 'has' : 'has no'} :dependent option") do
              unless association.class_name.start_with?(Audited.audit_class.name)
                refute_equal(association.options.key?(:dependent), conditioned,
                       if conditioned
                         'conditioned association is not responsible for :dependent objects'
                       else
                         'without the :dependent option this will lead to FK errors'
                       end + source_code_location(model, association))
              end
            end

            it('is using correct foreign_key') do
              class_name = association.class_name
              unless %w(:: Katello User Organization Docker Audited::Audit).any? { |word| class_name.start_with?(word) }
                class_name = "Katello::" + association.class_name
              end
              other_model = class_name.constantize
              foreign_key = association.foreign_key.to_s
              assert_includes other_model.column_names, foreign_key,
                     "unknown foreign_key #{foreign_key} on #{other_model}" + source_code_location(model, association)
            end
          end
        end
      end
    end
  end
end
