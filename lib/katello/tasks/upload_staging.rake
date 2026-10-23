namespace :katello do
  namespace :uploads do
    [:migrate, :cleanup].each do |operation|
      desc "Preview repository upload staging #{operation} (APPLY=true to apply)"
      task operation => :environment do
        require 'katello/upload_staging_migration'
        apply = ENV.fetch('APPLY', 'false')
        abort 'APPLY must be true or false' unless ['true', 'false'].include?(apply)
        counts = User.as_anonymous_admin do
          Katello::UploadStagingMigration.new(apply: apply == 'true', cleanup: operation == :cleanup,
            drained: ENV['CONFIRM_DRAINED'] == 'true').run
        end
        abort 'Some uploads could not be processed; original files were retained on failure' if counts[:failed].positive?
      end
    end
  end
end
