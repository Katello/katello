module Actions
  module Katello
    module Host
      module Erratum
        class Install < Actions::EntryAction
          include Helpers::Presenter

          def plan(host, errata_ids)
            Type! host, ::Host::Managed

            action_subject(host, :hostname => host.name, :errata => errata_ids)
            if Setting['erratum_install_batch_size'] && Setting['erratum_install_batch_size'] > 0
              errata_ids.each_slice(Setting['erratum_install_batch_size']) do |errata_ids_batch|
                plan_errata_install(host, errata_ids_batch)
              end
            else
              plan_errata_install(host, errata_ids)
            end
            plan_self(:host_id => host.id)
          end

          def humanized_name
            if input.try(:[], :hostname)
              _("Install erratum for %s") % input[:hostname]
            else
              _("Install erratum")
            end
          end

          def humanized_input
            [input[:errata].join(", ")] + super
          end

          def resource_locks
            :link
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Consumer::ContentInstall))
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: (_("Installation of errata requested: %{errata}") % {errata: input[:errata].join(", ")}).truncate(255))
          end

          private

          def plan_errata_install(host, errata_ids)
            if Setting['remote_execution_by_default']
              composer = JobInvocationComposer.for_feature(:katello_errata_install,
                                                           [host.id],
                                                           :errata => errata_ids.join(','))
              job_invocation = composer.job_invocation
              job_invocation.save!
              plan_action(RemoteExecution::RunHostsJob, job_invocation)
            else
              plan_action(Pulp::Consumer::ContentInstall,
                          consumer_uuid: host.content_facet.uuid,
                          type:          'erratum',
                          args:          errata_ids)
            end
          end
        end
      end
    end
  end
end
