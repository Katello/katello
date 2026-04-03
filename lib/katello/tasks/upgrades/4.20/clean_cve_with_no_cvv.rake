namespace :katello do
  namespace :upgrades do
    namespace '4.20' do
      desc "Remove CV Environments with no CVV id."
      task :clean_cve_with_no_cvv, [:commit] => ["environment"] do |_t, args|
        # To run without committing changes, use:
        # foreman-rake katello:upgrades:4.20:clean_cve_with_no_cvv[dry_run]
        commit = !(args[:commit].to_s == 'dry_run')
        msg_word = commit ? "Deleting" : "Listing"
        Rails.logger.info "#{msg_word} CVEs with no CVV id.\n"
        User.current = User.anonymous_admin
        ::Katello::ContentViewEnvironment.where(content_view_version: nil).find_each do |cve|
          Rails.logger.info "#{msg_word} CVE with id: #{cve.id} that has no CVV id.\n"
          if commit
            cve.destroy!
          end
        rescue StandardError => e
          Rails.logger.error "Error encountered when #{msg_word} record for CVE with id #{cve.id}: #{e}"
        end
      end
    end
  end
end
