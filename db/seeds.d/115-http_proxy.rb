if (SETTINGS[:katello][:cdn_proxy] && SETTINGS[:katello][:cdn_proxy][:host])
  config = SETTINGS[:katello][:cdn_proxy]
  uri = URI(config[:host])
  uri.user = nil
  uri.password = nil
  uri.port = config[:port] if config[:port]

  name = uri.host
  if (http_proxy = ::HttpProxy.where(name: name).first)
    http_proxy.update_attributes!(url: uri.to_s,
                                  username: config[:user],
                                  password: config[:password])
  else
    ::HttpProxy.create!(name: name,
                        url: uri.to_s,
                        username: config[:user],
                        password: config[:password])
  end

  if Setting[:content_default_http_proxy] != name
    Setting[:content_default_http_proxy] = name
  end
else
  Setting[:content_default_http_proxy] = ''
end
