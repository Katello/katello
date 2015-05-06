module Actions
  module Candlepin
    module Consumer
      class Update < Candlepin::Abstract
        def plan(system)
          plan_self(:uuid => system.uuid,
                    :facts => system.facts,
                    :guestIds => system.guestIds,
                    :installedProducts => system.installedProducts,
                    :autoheal => system.autoheal,
                    :releaseVer => system.releaseVer,
                    :serviceLevel => system.serviceLevel,
                    :cp_environment_id => system.cp_environment_id,
                    :capabilities => system.capabilities,
                    :lastCheckin => system.lastCheckin)
        end

        def run
          ::Katello::Resources::Candlepin::Consumer.update(input[:uuid],
                                                           input[:facts],
                                                           input[:guestIds],
                                                           input[:installedProducts],
                                                           input[:autoheal],
                                                           input[:releaseVer],
                                                           input[:serviceLevel],
                                                           input[:cp_environment_id],
                                                           input[:capabilities],
                                                           input[:lastCheckin])
        end
      end
    end
  end
end
