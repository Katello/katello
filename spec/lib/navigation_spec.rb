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

def check_menu_items(items)
  return if items.nil?
  keys = items.map { |i| i[:key] }
  keys.uniq.must_equal(keys)
  items.each do |item|
    check_menu_items(item[:items]) if item[:items] && item[:items].is_a?(Array)
  end
end

module Katello
  describe Navigation do

    before do
      AppConfig = double() unless defined?(AppConfig)
      AppConfig.stubs(:katello?) { true }

      @navigation_class = Class.new do

        class << self
          define_method(:helper_method) { |s| }
        end

        define_method(:_) { |s| s }
        def method_missing(*args)
          if args.first.to_s =~ /_path$/
            return "/"
          else
            super
          end
        end
        include Navigation
      end

      # create an instance
      @navigation       = @navigation_class.new
    end

    [:menu_main,
     :admin_main,
     :systems_navigation,
     :promotion_distribution_navigation,
     :organization_navigation,
     :system_groups_navigation,
     :gpg_keys_navigation,
     :activation_keys_navigation,
     :user_navigation,
     :promotion_errata_navigation,
     :custom_provider_navigation,
     :subscriptions_navigation,
     :new_subscription_navigation,
     :promotion_packages_navigation
    ].each do |menu|
      describe "##{menu} (katello)" do #TODO headpin
        subject { @navigation.send(menu) }
        specify { check_menu_items(subject) }
      end
    end

  end
end
