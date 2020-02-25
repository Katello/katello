namespace :katello do
  namespace :upgrades do
    namespace '3.10' do
      desc "Update repositories with API V1 GPG URLs"
      task :update_gpg_key_urls => ["environment", "katello:check_ping"] do
        User.current = User.anonymous_admin

        ::Organization.all.each do |org|
          org_contents = Katello::Resources::Candlepin::Content.all(org.label, include_only: [:id, :gpgUrl])

          org_contents.each do |cp_content|
            gpg_url = cp_content['gpgUrl']
            if gpg_url&.match(/katello\/api\/repositories/)
              content = Katello::Content.where(cp_content_id: cp_content['id'], organization: org).first

              if content.nil?
                Rails.logger.warn("Candlepin Content id=#{cp_content['id']} isn't in our DB. Try running 'rake katello:reimport' first.")
              else
                root_repo = Katello::RootRepository.in_organization(org).where(content_id: content.cp_content_id).first
                new_gpg_url = root_repo.library_instance.yum_gpg_key_url
                cp_content['gpgUrl'] = new_gpg_url
                Katello::Resources::Candlepin::Content.update(org.label, cp_content)
                content.gpg_url = new_gpg_url
                content.save!
              end
            end
          end
        end
      end
    end
  end
end
