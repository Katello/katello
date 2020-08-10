require 'test_helper'
require 'katello_test_helper'

class ContentViewHelperTest < ActionView::TestCase
  include ApplicationHelper
  include Katello::ContentViewHelper

  def setup
    @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
    @docker_repo1 = katello_repositories(:busybox)
    @docker_repo2 = katello_repositories(:busybox2)
    @yum_repo1 = katello_repositories(:fedora_17_x86_64)
    @yum_repo2 = katello_repositories(:rhel_7_x86_64)
    @file_repo1 = katello_repositories(:pulp3_file_1)
    @file_repo2 = katello_repositories(:generic_file_dev)

    SETTINGS[:katello][:use_pulp_2_for_content_type] = {}
    SETTINGS[:katello][:use_pulp_2_for_content_type][:yum] = false
    SETTINGS[:katello][:use_pulp_2_for_content_type][:docker] = false
    SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = true
  end

  def teardown
    SETTINGS[:katello][:use_pulp_2_for_content_type] = nil
  end

  test 'separated_repo_mapping must separate Pulp 3 yum repos from others' do
    repo_map = { [@docker_repo1] => @docker_repo2, [@yum_repo1] => @yum_repo2, [@file_repo1] => @file_repo2 }
    separated_repo_map = separated_repo_mapping(repo_map)

    assert_equal separated_repo_map, { :pulp3_yum => { [@yum_repo1] => @yum_repo2 },
                                       :other => { [@docker_repo1] => @docker_repo2, [@file_repo1] => @file_repo2 } }
  end

  test 'separated_repo_mapping must not separate Pulp 2 yum repos from others' do
    SETTINGS[:katello][:use_pulp_2_for_content_type][:yum] = true

    repo_map = { [@docker_repo1] => @docker_repo2, [@yum_repo1] => @yum_repo2, [@file_repo1] => @file_repo2 }
    separated_repo_map = separated_repo_mapping(repo_map)

    assert_equal separated_repo_map, { :pulp3_yum => {}, :other => repo_map }
  end
end
