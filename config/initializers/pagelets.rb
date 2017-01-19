# initialize katello related pagelets
mgr = Pagelets::Manager.new "hosts/_form"

mgr.add_pagelet :main_tab_fields,
  :partial => "overrides/activation_keys/host_environment_select",
  :priority => 80
