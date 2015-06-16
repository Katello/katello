module Katello
  class DashboardRegisterer
    WIDGETS = [
      {:template=>'foreman/overrides/about/system_status', :sizex=>6, :sizey=>1, :name=> N_('Backend System Status')}
    ]

    def self.register_widgets
      if ForemanTasks.dynflow.required?
        WIDGETS.each do |widget|
          ::Dashboard::Manager.register_default_widget(widget)
        end
      end
    end
  end
end
