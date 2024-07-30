class AddContentViewEnvironmentActivationKey < ActiveRecord::Migration[6.1]
  class FakeActivationKey < ApplicationRecord
    self.table_name = 'katello_activation_keys'
  end

  def up
    create_table :katello_content_view_environment_activation_keys do |t|
      t.references :content_view_environment, :null => false, :index => false, :foreign_key => { :to_table => 'katello_content_view_environments' }
      t.references :activation_key, :null => false, :index => false, :foreign_key => { :to_table => 'katello_activation_keys' }
    end
    ::Katello::Util::CVEAKMigrator.new.execute!
    FakeActivationKey.all.each do |activation_key|
      next if activation_key.environment_id.blank? && activation_key.content_view_id.blank?

      cve_id = ::Katello::KTEnvironment.find(activation_key.environment_id)
          .content_view_environments
          .find_by(content_view_id: activation_key.content_view_id)
          &.id
      unless cve_id.present? && ::Katello::ContentViewEnvironmentActivationKey.create(
        activation_key_id: activation_key.id,
        content_view_environment_id: cve_id
      )
        Rails.logger.warn "Failed to create ContentViewEnvironmentActivationKey for activation_key #{activation_key.id}"
      end
    end

    remove_column :katello_activation_keys, :content_view_id
    remove_column :katello_activation_keys, :environment_id
  end

  def down
    add_column :katello_activation_keys, :content_view_id, :integer, :index => true
    add_column :katello_activation_keys, :environment_id, :integer, :index => true

    add_foreign_key "katello_activation_keys", "katello_content_views",
                    :name => "katello_activation_keys_content_view_id", :column => "content_view_id"

    add_foreign_key "katello_activation_keys", "katello_environments",
                    :name => "katello_activation_keys_environment_id", :column => "environment_id"

    ::Katello::ActivationKey.reset_column_information

    ::Katello::ContentViewEnvironmentActivationKey.unscoped.all.each do |cveak|
      activation_key = cveak.activation_key
      cve = cveak.content_view_environment
      default_org = cve.environment&.organization
      default_cv_id = default_org&.default_content_view&.id
      default_lce_id = default_org&.library&.id
      cv_id = cveak.content_view_environment.content_view_id || default_cv_id
      lce_id = cveak.content_view_environment.environment_id || default_lce_id
      say "Updating activation_key #{activation_key.id} with cv_id #{cv_id} and lce_id #{lce_id}"
      activation_key.content_view_id = cv_id
      activation_key.environment_id = lce_id
      activation_key.save(validate: false)
    end

    ensure_no_null_cv_lce
    change_column :katello_activation_keys, :content_view_id, :integer, :null => false
    change_column :katello_activation_keys, :environment_id, :integer, :null => false

    drop_table :katello_content_view_environment_activation_keys
  end

  def ensure_no_null_cv_lce
    # The following is to try to prevent PG::NotNullViolation: ERROR:  column "content_view_id" contains null values
    # since we add null constraints to the columns in the next step
    activation_keys_without_cv = ::Katello::ActivationKey.where(content_view_id: nil)
    if activation_keys_without_cv.any?
      say "Found #{activation_keys_without_cv.count} activation_keys with nil content_view_id"
      activation_keys_without_cv.each do |activation_key|
        say "reassigning bad activation_key #{activation_key.id} to default content view"
        activation_key.content_view_id = activation_key&.organization&.default_content_view&.id
        activation_key.save(validate: false)
      end
    end

    activation_keys_without_lce = ::Katello::ActivationKey.where(environment_id: nil)
    if activation_keys_without_lce.any?
      say "Found #{activation_keys_without_lce.count} activation_keys with nil environment_id"
      activation_keys_without_lce.each do |activation_key|
        say "reassigning bad activation_key #{activation_key.id} to default lifecycle environment"
        activation_key.environment_id = activation_key&.organization&.library&.id
        activation_key.save(validate: false)
      end
    end
  end
end
