module Katello
  module Validators
    class HostgroupKickstartRepositoryValidator < ActiveModel::Validator
      def validate(facet)
        return unless facet.kickstart_repository_id

        msg = if facet.content_source.blank?
                _("Please select a content source before assigning a kickstart repository")
              elsif facet.hostgroup.operatingsystem.blank?
                _("Please select an operating system before assigning a kickstart repository")
              elsif !facet.hostgroup.operatingsystem.is_a?(Redhat)
                _("Kickstart repositories can only be assigned to hosts in the Red Hat family")
              elsif facet.hostgroup.architecture.blank?
                _("Please select an architecture before assigning a kickstart repository")
              elsif !facet.hostgroup.matching_kickstart_repository?(facet)
                _("The selected kickstart repository is not part of the assigned content view, lifecycle environment,
                  content source, operating system, and architecture")
              end

        facet.errors.add(:base, msg) if msg
      end
    end
  end
end
