module Actions
  module Foreman
    module Environment
      class Destroy < Actions::Base
        def plan(environment)
          if environment.hosts.count > 0
            names = environment.hosts.limit(5).pluck(:name).join(', ')
            fail _("The puppet environment %{name} is in use by %{count} Host(s) including %{names}") %
                     {:name => environment.name, :names => names, :count => environment.hosts.count}
          end

          if environment.hostgroups.count > 0
            names = environment.hostgroups.limit(5).pluck(:name).join(', ')
            fail _("The puppet environment %{name} is in use by %{count} Host Group(s) including %{names}") %
                     {:name => environment.name, :names => names, :count => environment.hostgroups.count}
          end

          environment.destroy!
        end
      end
    end
  end
end
