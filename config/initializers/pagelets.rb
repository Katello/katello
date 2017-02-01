# initialize katello related pagelets
Pagelets::Manager.with_key "hosts/_form" do |mgr|
  mgr.add_pagelet :main_tab_fields,
    :partial => "overrides/activation_keys/host_environment_select",
    :priority => 80
end
