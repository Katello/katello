require 'katello_test_helper'
module Katello
  module Service
    module Pulp3
      class MigrationPlanTest < ActiveSupport::TestCase
        def setup
          repo_label = 'foo'
          repoa = katello_repositories(:fedora_17_x86_64_library_view_2)
          repob = katello_repositories(:rhel_6_x86_64_dev_archive)

          repoa.root.update_column(:label, repo_label)
          repob.root.update_column(:label, repo_label)
        end

        def test_conflicting_labels
          plan = Katello::Pulp3::MigrationPlan.new(['yum']).generate
          name_list = plan[:plugins].first[:repositories].map { |i| i[:name] }
          assert_equal name_list.size, name_list.uniq.size
          assert_include name_list, 'published_dev_view-foo'
        end
      end
    end
  end
end
