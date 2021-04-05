require 'katello_test_helper'
require 'rake'

module Katello
  class SyncNoarchContentTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/4.1/sync_noarch_content'
      Rake::Task['katello:upgrades:4.1:sync_noarch_content'].reenable
      Rake::Task.define_task(:environment)
    end

    def test_sync_content_with_noarch_repository
      count = Katello::RootRepository.joins(:product).merge(Katello::Product.custom).update_all(arch: 'noarch')
      assert_operator count, :>=, 1
      Katello::Resources::Candlepin::Content.expects(:update).times(count)

      Rake.application.invoke_task('katello:upgrades:4.1:sync_noarch_content')
    end

    def test_no_sync_with_set_arch_repository
      Katello::RootRepository.joins(:product).merge(Katello::Product.custom).where(arch: 'noarch').update_all(arch: 'i386')
      Katello::Resources::Candlepin::Content.expects(:update).never

      Rake.application.invoke_task('katello:upgrades:4.1:sync_noarch_content')
    end
  end
end
