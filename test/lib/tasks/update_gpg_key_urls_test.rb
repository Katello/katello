require 'katello_test_helper'
require 'rake'

module Katello
  class UpdateGpgKeyUrlTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/upgrades/3.10/update_gpg_key_urls'
      Rake.application.rake_require 'katello/tasks/reimport'
      Rake::Task['katello:upgrades:3.10:update_gpg_key_urls'].reenable
      Rake::Task['katello:check_ping'].reenable
      Rake::Task.define_task(:environment)
      Rake::Task.define_task('dynflow:client')
    end

    def test_update_gpg_key_urls
      Katello::Ping.expects(:ping).returns(:status => 'ok')

      contents = [
        {
          'id' => 123_456,
          'gpgUrl' => '../../katello/api/repositories/100/gpg_key_content'
        },
        {
          'id' => 654_321,
          'gpgUrl' => '../../katello/api/v2/repositories/200/gpg_key_content'
        }
      ]

      product = Organization.first.products.first
      contents.each do |cp_content|
        FactoryBot.create(:katello_root_repository, content_id: cp_content['id'], product: product)
        content = FactoryBot.create(:katello_content, cp_content_id: cp_content['id'], organization: Organization.first)
        FactoryBot.create(:katello_product_content, content: content, product: product)
      end

      library_instance = katello_repositories(:fedora_17_x86_64)
      Katello::RootRepository.any_instance.stubs(:library_instance).returns(library_instance)

      expected_gpg_url = "../../katello/api/v2/repositories/#{library_instance.id}/gpg_key_content"

      Katello::Resources::Candlepin::Content.stubs(:all).returns(contents)
      Katello::Resources::Candlepin::Content.expects(:update).once.with(Organization.first.label, 'id' => 123_456, 'gpgUrl' => expected_gpg_url)

      Rake.application.invoke_task('katello:upgrades:3.10:update_gpg_key_urls')

      assert_nil Katello::Content.where(cp_content_id: 654_321).first.gpg_url
      assert_equal expected_gpg_url, Katello::Content.where(cp_content_id: 123_456).first.gpg_url
    end
  end
end
