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

require 'katello_test_helper'

module Katello
  describe 'associations' do
    def location(model, association)
      path     = "#{Katello::Engine.root}/app/models/#{model.name.underscore}.rb"
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

    ActiveRecord::Base.subclasses.each do |model|
      next unless model.table_name.starts_with?('katello_')

      describe model do
        model.reflect_on_all_associations(:belongs_to).each do |association|
          describe "belongs_to: #{association.name.inspect}" do
            next if association.options.key? :polymorphic

            it('has :inverse_of option') do
              assert association.options.key?(:inverse_of),
                'inverse association cannot be found without the option set' +
                location(model, association)
            end

            it('inverse association exists') do
              assert association.inverse_of,
                'the inverse association which would take care of deletion avoiding FK errors could not be found' +
                location(model, association)
            end

            it('is using correct foreign_key') do
              assert model.column_names.include?(fk = association.foreign_key.to_s),
                "unknown foreign_key #{fk}" + location(model, association)
            end
          end
        end

        associations = model.reflect_on_all_associations(:has_many) + model.reflect_on_all_associations(:has_one)
        associations.each do |association|
          next if association.options.key?(:through)
          conditioned = association.options.key? :conditions
          describe "has_(many|one): #{association.name.inspect} #{'with conditions' if conditioned}" do
            it("#{conditioned ? 'has' : 'has not'} :dependent option") do
              assert(association.options.key?(:dependent) != conditioned,
                     if conditioned
                       'conditioned association is not responsible for :dependent objects'
              else
                'without the :dependent option this will lead to FK errors'
              end + location(model, association))
            end

            it('is using correct foreign_key') do
              other_model = association.class_name.constantize
              foreign_key = association.foreign_key.to_s
              assert other_model.column_names.include?(foreign_key),
                "unknown foreign_key #{foreign_key} on #{other_model}" + location(model, association)
            end
          end
        end
      end
    end
  end
end
