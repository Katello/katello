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
describe 'model associations' do
  it 'there is no :has_many or :has_one association with missing :dependent option' do
    associations_without_dependent = ActiveRecord::Base.subclasses.each_with_object({}) do |model, bad_models|
      associations     = model.reflect_on_all_associations(:has_many) + model.reflect_on_all_associations(:has_one)
      bad_associations = associations.each_with_object([]) do |association, bad_associations|
        unless association.options.key?(:through) || association.options.key?(:dependent)
          bad_associations << association.name
        end
      end
      bad_models.update model.name => bad_associations unless bad_associations.empty?
    end

    # only katello models
    associations_without_dependent.select! { |assoc| assoc =~ /Katello::/ }

    assert associations_without_dependent.empty?,
           "Following associations are missing :dependent option\n" +
               "#{associations_without_dependent.pretty_inspect}"
  end
end
end
