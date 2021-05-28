# Used exclusively by fix_hostgroup_facets.rake task
module Katello
  module Util
    class HostgroupFacetsHelper
      def initialize
        @logger = Logger.new($stdout)
      end

      def interested_hostgroups
        groups = ::Hostgroup.unscoped.where(
                    id: Katello::Hostgroup::ContentFacet.
                        where(content_source_id: nil,
                              kickstart_repository_id: nil,
                              content_view_id: nil,
                              lifecycle_environment_id: nil).select(:hostgroup_id))
        parents = groups.select { |group| group.parent.blank? }
        children = groups.reject { |group| group.parent.blank? }
        # we want the parents to get created before the children
        # hence the order
        parents + children
      end

      def pick_facet_values(hg)
        # This call looks at the audit logs for a host group.
        # Pries out information related to lce, ks, cv and content_source_id from the audit logs.
        # The audit logs typically only contain updates.
        # So if the user changed  just the content_view_id, then that is the only thing marked as audited_changes.
        # Hence we need to go through all the audit logs until we have information on lce, ks, cv and cs.
        # If there was only one audit log and that was during the creation of hostgroup
        # the audited changes look like this
        # ```ruby
        # {
        #  content_view_id: 10,
        #  kickstart_repository_id: 1000
        #  ......
        # }
        # ```
        # However if you updated the hostgroup and set the kickstart_repository_id, or
        # content_view_id then audited changes look like
        # ```ruby
        # {
        #  content_view_id: [10, 11],
        #  kickstart_repository_id: [1000, 1200]
        #  ......
        # }
        # ```
        # So the code says "if the attribute value is an array pick the last value else just keep the value as it is "

        # Further along it is to be noted that `hostgroup.audits` returns the audits ordered by the version number in ascending order, so the latest audit will be `hostgroup.audits.last`

        # We want to iterate though each audit from latest audit to start, and as soon as we find a  content_view_id key or kickstart_repository_id key or lifecycle environment_id key  or content_source_id key we want it to be set once.

        # So if I had an audit history like
        # ``` ruby
        # {
        #  content_view_id: 10,
        #  kickstart_repository_id: 1000,
        #  version:1
        #  ......
        # },
        # {
        #  content_view_id: [10, 11],
        #  kickstart_repository_id: [1000, 1200],
        #   version: 2
        #  ......
        # }
        # ```

        # The code would start at version 2, notice that cv_id and ks_repo were set there
        # and keep them as the final.
        # So when it goes to version 1 since cv_id and ks_repo are already set,
        # it will ignore. It will finally
        # return {content_view_id: 11, kickstart_repository_id: 1200}
        facet_values = {}
        hg.audits.reverse_each do |audit|
          hg_changes = audit.audited_changes.slice("lifecycle_environment_id",
                                                   "kickstart_repository_id",
                                                   "content_view_id",
                                                   "content_source_id")
          facet_values = hg_changes.merge(facet_values)
        end

        values = facet_values.map do |k, v|
          v = v[-1] if v.is_a? Array
          [k, v]
        end
        values.to_h.with_indifferent_access
      end

      def main
        bad_hgs = []
        good_hgs = []

        groups = interested_hostgroups.each do |hg|
          facet = hg.content_facet
          values = pick_facet_values(hg)
          if !values.empty? && facet.update(values)
            good_hgs << { hostgroup: hg, facet_values: values }
          else
            bad_hgs << { hostgroup: hg, facet_values: values }
            facet.save(validate: false)
          end
        end

        unless bad_hgs.empty?
          @logger.warn "Some of the hostgroups reported a validation error. "\
                        "The hostgroups have been updated. "\
                        "Check via the Web UI."

          bad_hgs.each do |bad_group|
            @logger.warn "Hostgroup #{bad_group[:hostgroup]}"
            @logger.warn "Facet Values #{bad_group[:facet_values]}"
          end
        end
        unless good_hgs.empty?
          @logger.info "Following hostgroups were succesfully updated."
          good_hgs.each do |good_group|
            @logger.info "Hostgroup #{good_group[:hostgroup]}"
            @logger.info "Facet Values #{good_group[:facet_values]}"
          end
        end
        @logger.info("#{groups.count} Hostgroup(s) were updated.")
      end
    end
  end
end
