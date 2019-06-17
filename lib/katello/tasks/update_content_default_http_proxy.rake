require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Sets the content default http proxy to an existing http proxy based on supplied URL."
  task :update_default_http_proxy, [:proxy_name] => [ :environment] do |_task, args|
    setting = ::Setting::Content.where(name: 'content_default_http_proxy').first

    http_proxy = HttpProxy.where(name: args[:proxy_name]).first

    if http_proxy
      setting.update_attribute(:value, http_proxy.name)
      puts "Content default http proxy set to #{http_proxy.name_and_url}."
    else
      $stderr.print "No http proxy found with name \"#{args[:proxy_name]}\"."
    end
  end

  desc "Displays the current defined http proxies."
  task http_proxy_list: [:environment] do
    ::HttpProxy.all.each { |proxy| puts "#{proxy.name_and_url}" }
  end
end
