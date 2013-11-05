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

FactoryGirl.define do
  factory :content_view, :class => Katello::ContentView do
    sequence(:name) { |n| "Database#{n}" }
    description "This content view is for database content"
    organization

    trait :with_definition do
      association :content_view_definition,
        :factory => :content_view_definition
    end

    factory :content_view_with_definition, :traits => [:with_definition]
  end

end
