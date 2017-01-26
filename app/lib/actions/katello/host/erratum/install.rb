module Actions
  module Katello
    module Host
      module Erratum
        class Install < Actions::EntryAction
          include Helpers::Presenter

          def plan(host, errata_ids)
            Type! host, ::Host::Managed

            action_subject(host, :errata => errata_ids)
            if Setting['erratum_install_batch_size'] && Setting['erratum_install_batch_size'] > 0
              errata_ids.each_slice(Setting['erratum_install_batch_size']) do |errata_ids_batch|
                plan_action(Pulp::Consumer::ContentInstall,
                            consumer_uuid: host.content_facet.uuid,
                            type:          'erratum',
                            args:          errata_ids_batch)
              end
            else
              plan_action(Pulp::Consumer::ContentInstall,
                          consumer_uuid: host.content_facet.uuid,
                          type:          'erratum',
                          args:          errata_ids)
            end
          end

          def humanized_name
            _("Install erratum")
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
        end
      end
    end
  end
end
