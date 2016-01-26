Deface::Override.new(
  :virtual_path => 'smart_proxies/index',
  :name => 'disable_turbolinks_on_proxies_index',
  :set_attributes => '.proxy-show',
  :attributes => {'data-no-turbolink' => 'true'})
