module Katello
  module Validators
    class HostgroupKickstartRepositoryValidator < ActiveModel::Validator
      def validate(hostgroup)
        # check content source first, otherwise it's meaningless to proceed
        if hostgroup.content_source && hostgroup.lifecycle_environment
          valid = hostgroup.content_source.lifecycle_environments.include?(hostgroup.lifecycle_environment)
          hostgroup.errors.add(:base, _("The selected content source and lifecycle environment do not match")) && return unless valid
        end

        return unless hostgroup.kickstart_repository_id

        msg = if hostgroup.content_source.blank?
                hostgroup.errors.add(:base, _("Please select a content source before assigning a kickstart repository"))
              elsif hostgroup.operatingsystem.blank?
                _("Please select an operating system before assigning a kickstart repository")
              elsif !hostgroup.operatingsystem.is_a?(Redhat)
                _("Kickstart repositories can only be assigned to hosts in the Red Hat family")
              elsif hostgroup.architecture.blank?
                _("Please select an architecture before assigning a kickstart repository")
              elsif hostgroup.operatingsystem.kickstart_repos(hostgroup).none? { |repo| repo[:id] == hostgroup.kickstart_repository_id }
                _("The selected kickstart repository is not part of the assigned content view, lifecycle environment,
                  content source, operating system, and architecture")
              end

        hostgroup.errors.add(:base, msg) if msg
      end
    end
  end
end
