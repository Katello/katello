module Katello
  module Validators
    class HostgroupKickstartRepositoryValidator < ActiveModel::Validator
      def validate(facet)
        return unless facet.kickstart_repository_id
        if facet.content_source.blank? && facet.hostgroup.content_source.blank?
          prop = :content_source
          msg = _("Please select a content source before assigning a kickstart repository")
        elsif facet.hostgroup.operatingsystem.blank?
          prop = :base
          msg = _("Please select an operating system before assigning a kickstart repository")
        elsif !facet.hostgroup.operatingsystem.is_a?(Redhat)
          prop = :base
          msg = _("Kickstart repositories can only be assigned to hosts in the Red Hat family")
        elsif facet.hostgroup.architecture.blank?
          prop = :base
          msg = _("Please select an architecture before assigning a kickstart repository")
        elsif !content_view_in_env?(facet)
          prop = :lifecycle_environment
          msg = _("The selected/Inherited Content View is not available for this Lifecycle Environment")
        elsif !facet.hostgroup.matching_kickstart_repository?(facet)
          prop = :kickstart_repository
          msg = _("The selected kickstart repository is not part of the assigned content view, " \
                  "lifecycle environment, content source, operating system, and architecture")
        end
        facet.hostgroup.errors.add(prop, msg) if msg
      end

      def content_view_in_env?(facet)
        cvenv = facet.content_view_environment || facet.hostgroup.content_view_environment
        return false if cvenv.blank?
        cvenv.environment.content_views.include?(cvenv.content_view)
      end
    end
  end
end
