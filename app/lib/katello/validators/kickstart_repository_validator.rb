module Katello
  module Validators
    class KickstartRepositoryValidator < ActiveModel::Validator
      def validate(record)
        ks_repo_id = kickstart_repository_id(record)
        return unless ks_repo_id && kickstart_repository_changed(record)

        msg = if record.operatingsystem.blank?
                _("Please select an operating system before assigning a kickstart repository")
              elsif record.architecture.blank?
                _("Please select an architecture before assigning a kickstart repository")
              elsif !record.operatingsystem.is_a?(Redhat)
                _("Kickstart repositories can only be assigned to hosts in the Red Hat family")
              elsif record.content_source.blank?
                _("Please select a content source before assigning a kickstart repository")
              elsif record.operatingsystem.kickstart_repos(record).none? { |repo| repo[:id] == ks_repo_id }
                _("The selected kickstart repository is not part of the assigned content view, lifecycle environment,
                  content source, operating system, and architecture")
              end
        record.errors.add(:base, msg) if msg
      end

      private

      def kickstart_repository_changed(record)
        if record.is_a?(::Hostgroup)
          record.kickstart_repository_id_changed?
        else
          record.content_facet.kickstart_repository_id_changed?
        end
      end

      def kickstart_repository_id(record)
        if record.is_a?(::Hostgroup)
          record.kickstart_repository_id
        elsif record.content_facet.present?
          record.content_facet.kickstart_repository_id
        end
      end
    end
  end
end
