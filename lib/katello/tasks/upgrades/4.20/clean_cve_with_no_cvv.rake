namespace :katello do
  namespace :upgrades do
    namespace '4.20' do
      desc "Remove CV Environments with no CVV id."
      task :clean_cve_with_no_cvv => ["environment"] do
        User.current = User.anonymous_admin
        remove_cve_with_no_cvv 
      end

      def remove_cve_with_no_cvv
        ::Katello::ContentViewEnvironment.select { |c| c.content_view_version.nil? }&.each do |cve|
          Rails.logger.info "Deleting CVE with id: #{cve.id} that has no CVV id.\n"
          cve.destroy
        end
      rescue RuntimeError => e
        Rails.logger.error "Task failed: #{e}"
      end
end
