require File.expand_path("../engine", File.dirname(__FILE__))
require 'yaml'

namespace :katello do
  desc "Imports the content default http proxy from the foreman-installer answer file."
  task :import_default_http_proxy => :environment do

    answers_file = "/etc/foreman-installer/scenarios.d/satellite-answers.yaml"
    puts "Using answer file at #{answers_file}"
    unless File.readable?(answers_file)
      $stderr.print("Coulnd't read answers file at #{answers_file}")
      exit 1
    end

    answers = YAML.load_file(answers_file)
    provision_global_default_http_proxy(answers)
    exit
  end

  def provision_global_default_http_proxy(answers)
    if answers['katello'].nil?
      $stderr.print("Answers didn't have a 'katello' section.")
      exit 1
    end

    if answers['katello']['proxy_url'].nil?
      $stderr.print("Answers 'katello' section didn't have a 'proxy_url' value.")
      exit 1
    end

    uri = URI(answers['katello']['proxy_url'])

    uri.port = answers['katello']['proxy_port'] if answers['katello']['proxy_port']
    sanitized_url = uri.to_s

    proxy_name = uri.host
    proxy_username = uri.user
    if answers['katello']['proxy_username']
      proxy_username = answers['katello']['proxy_username']
    end

    proxy_password = uri.password
    if answers['katello']['proxy_password']
      proxy_password = answers['katello']['proxy_password']
    end

    if HttpProxy.where(name: proxy_name).any?
      proxy_name += ' (global)'
    end

    User.current = User.anonymous_api_admin
    new_proxy = ::HttpProxy.new(
      name: proxy_name,
      url: sanitized_url,
      username: proxy_username,
      password: proxy_password,
      organizations: Organization.all,
      locations: Location.all)

    if new_proxy.save!
      setting = ::Setting.find_by(name: 'content_default_http_proxy')
      setting.update_attribute(:value, new_proxy.name)
      puts "Default content http proxy set to #{new_proxy.name_and_url}."
    end
  end
end
