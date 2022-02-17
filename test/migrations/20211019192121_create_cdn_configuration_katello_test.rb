require 'katello_test_helper'
require Katello::Engine.root.join('db/migrate/20211019192121_create_cdn_configuration.katello')

module Katello
  class CreateCdnConfigurationTest < ActiveSupport::TestCase
    let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths + [Katello::Engine.root.join('db/migrate/').to_s] }
    #let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths, ActiveRecord::SchemaMigration).migrations }
    let(:previous_version) { '20211006161617'.to_i }
    let(:current_version) { '20211019192121'.to_i }

    #only load the two migrations we care about (previous one and current one)
    let(:migrations) do
      [
        ActiveRecord::MigrationProxy.new("AddFilenameToKatelloGenericContentUnits", previous_version, "#{Katello::Engine.root}/db/migrate/20211006161617_add_filename_to_katello_generic_content_units.rb", ""),
        ActiveRecord::MigrationProxy.new("CreateCdnConfiguration", current_version, "#{Katello::Engine.root}/db/migrate/20211019192121_create_cdn_configuration.katello.rb", "")
      ]
    end

    def migrate_up
      ActiveRecord::Migrator.new(:up, migrations, ActiveRecord::SchemaMigration, current_version).migrate
    end

    def setup
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:down, migrations, ActiveRecord::SchemaMigration, previous_version).migrate
      end
      ::Katello::Provider.reset_column_information
    end

    def test_cdn_configuration_successful_migration
      repo_url = "http://foobar.com"
      organization = get_organization
      organization.redhat_provider.update_column(:repository_url, repo_url)
      migrate_up
      assert_equal "http://foobar.com", organization.reload.cdn_configuration.url
    end
  end
end
