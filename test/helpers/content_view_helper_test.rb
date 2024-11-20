require 'test_helper'
require 'katello_test_helper'

class ContentViewHelperTest < ActionView::TestCase
  include ApplicationHelper
  include Katello::ContentViewHelper

  def setup
    @primary = SmartProxy.pulp_primary
    @deb_repo1 = katello_repositories(:debian_10_amd64)
    @deb_repo2 = katello_repositories(:debian_9_amd64)
    @docker_repo1 = katello_repositories(:busybox)
    @docker_repo2 = katello_repositories(:busybox2)
    @yum_repo1 = katello_repositories(:fedora_17_x86_64)
    @yum_repo2 = katello_repositories(:rhel_7_x86_64)
    @file_repo1 = katello_repositories(:pulp3_file_1)
    @file_repo2 = katello_repositories(:generic_file_dev)
  end

  def teardown
    SETTINGS[:katello][:use_pulp_2_for_content_type] = nil
  end

  test 'separated_repo_mapping must separate Pulp 3 deb/yum repos from others if using multi-copy actions' do
    repo_map = { [@docker_repo1] => @docker_repo2, [@deb_repo1] => @deb_repo2, [@yum_repo1] => @yum_repo2, [@file_repo1] => @file_repo2 }
    separated_repo_map = separated_repo_mapping(repo_map, true)

    assert_equal separated_repo_map, { :pulp3_deb_multicopy => { [@deb_repo1] => @deb_repo2 }, :pulp3_yum_multicopy => { [@yum_repo1] => @yum_repo2 },
                                       :other => { [@docker_repo1] => @docker_repo2, [@file_repo1] => @file_repo2 } }
  end

  test 'separated_repo_mapping must not separate Pulp 3 deb/yum repos from others if not using multi-copy actions' do
    repo_map = { [@docker_repo1] => @docker_repo2, [@deb_repo1] => @deb_repo2, [@yum_repo1] => @yum_repo2, [@file_repo1] => @file_repo2 }
    separated_repo_map = separated_repo_mapping(repo_map, false)

    assert_equal separated_repo_map, { :pulp3_deb_multicopy => { }, :pulp3_yum_multicopy => { },
                                       :other => { [@yum_repo1] => @yum_repo2, [@docker_repo1] => @docker_repo2,
                                                   [@deb_repo1] => @deb_repo2, [@file_repo1] => @file_repo2 } }
  end
end
