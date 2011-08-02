#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'rubygems'
require 'rest_client'
require 'http_resource'

module Pulp

  class Proxy
    def self.post path, body
      Rails.logger.debug "Sending POST request to Pulp: #{path}"
      client = PulpResource.rest_client(Net::HTTP::Post, :post, path_with_pulp_prefix(path))
      client.post body, PulpResource.default_headers
    end

    def self.delete path
      Rails.logger.debug "Sending DELETE request to Pulp: #{path}"
      client = PulpResource.rest_client(Net::HTTP::Delete, :delete, path_with_pulp_prefix(path))
      client.delete(PulpResource.default_headers)
    end

    def self.get path
      Rails.logger.debug "Sending GET request to Pulp: #{path}"
      client = PulpResource.rest_client(Net::HTTP::Get, :get, path_with_pulp_prefix(path))
      client.get(PulpResource.default_headers)
    end

    def self.path_with_pulp_prefix path
      PulpResource.prefix + path
    end
  end

  class PulpResource < HttpResource
    cfg = AppConfig.pulp
    url = cfg.url
    self.prefix = URI.parse(url).path
    self.site = url.gsub(self.prefix, "")
    self.consumer_secret = cfg.oauth_secret
    self.consumer_key = cfg.oauth_key
    self.ca_cert_file = cfg.ca_cert_file

    def self.default_headers
      {'accept' => 'application/json', 'content-type' => 'application/json'}.merge(User.current.pulp_oauth_header)
    end
  end

  class PulpPing < PulpResource
    class << self
      def ping
        # For now we have to query repositories because there is no
        # URL that is available in Pulp that returns something small
        # but requires authentication.  Please do not change this to
        # /pulp/api/services/status/ because that path does *not* require
        # auth and will not accurately report if Katello can talk
        # to Pulp using OAuth.
        response = get('/pulp/api/users/', self.default_headers).body
        JSON.parse(response)
      end
    end
  end

  class Package < PulpResource

    class << self

      # Get all the Repositories known by Pulp
      def all
        response = get(package_path, self.default_headers).body
        JSON.parse(response)
      end

      def find id
        response = get(package_path + id + "/", self.default_headers).body
        JSON.parse(response)
      end

      def package_path
        "/pulp/api/packages/"
      end

      def dep_solve pkgnames, repoids
        path = "/pulp/api/services/dependencies/"
        response = post(path, JSON.generate({:pkgnames=>pkgnames, :repoids=>repoids}),  self.default_headers)
        JSON.parse(response)["available_packages"]
      end


    end
  end

  class Errata < PulpResource

    class << self
      def find errata_id
        response = get(errata_path + errata_id + "/", self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def errata_path
        "/pulp/api/errata/"
      end
    end
  end

  class Distribution < PulpResource

    class << self
      def find dist_id
        response = get(dist_path + dist_id + "/", self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def dist_path
        "/pulp/api/distribution/"
      end
    end
  end

  class Repository < PulpResource
    class << self

      def clone_repo from_repo, to_repo, feed = "parent"  #clone is a built in method, hence redundant name
        data = {:clone_id => to_repo.id, :feed =>feed, :clone_name => to_repo.name, :groupid=>to_repo.groupid}
        path = Repository.repository_path + from_repo.id + "/clone/"
        response = post(path, JSON.generate(data), self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def find repo_id, yell_on_404 = false
        response = get(repository_path  + repo_id + "/", self.default_headers)
        body = response.body
        JSON.parse(body).with_indifferent_access
      rescue RestClientException => e
        return nil if e.code.to_i == 404 && !yell_on_404
        raise e
      end

      # Get all the Repositories known by Pulp
      def all groupids=nil
        custom = self.repository_path
        if groupids
            custom += "?" + groupids.collect{|id| "groupid=#{url_encode(id)}"}.join("&")
        end
        response = get(custom , self.default_headers)
        body = response.body
        JSON.parse(body)
      rescue RestClientException => e
        return nil if e.code.to_i == 404 && !yell_on_404
        raise e
      end

      def start_discovery url, type
        response = post("/pulp/api/services/discovery/repo/", JSON.generate(:url => url, :type => type), self.default_headers)
        return JSON.parse(response.body).with_indifferent_access if response.code == 202
        Rails.logger.error("Failed to start repository discovery. HTTP status: #{response.code}. #{response.body}")
        raise RuntimeError, "#{response.code}, failed to start repository discovery: #{response.body}"
      end

      def discovery_status task_id
        response = get("/pulp/api/services/discovery/repo/#{task_id}/", self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def repository_path
        "/pulp/api/repositories/"
      end

      # :id, :name, :arch, :groupid, :feed
      def create attrs
        body = put(Repository.repository_path, JSON.generate(attrs), self.default_headers).body
        JSON.parse(body).with_indifferent_access
      end

      # :id, :name, :arch, :groupid, :feed
      def update repo_id, attrs
        body = put(Repository.repository_path + repo_id +"/", JSON.generate(attrs), self.default_headers).body
        find repo_id
      end

      def add_packages repo_id, pkg_id_list
        body = post(Repository.repository_path + repo_id +"/add_package/", {:packageid=>pkg_id_list}.to_json, self.default_headers).body
      end

      def add_errata repo_id, errata_id_list
        body = post(Repository.repository_path + repo_id +"/add_errata/", {:errataid=>errata_id_list}.to_json, self.default_headers).body
      end

      def destroy repo_id
        raise ArgumentError, "repo id has to be specified" unless repo_id
        self.delete(repository_path  + repo_id + "/", self.default_headers).code.to_i
      end

      def sync (repo_id, data = {})
        path = Repository.repository_path + repo_id + "/sync/"
        response = post(path, JSON.generate(data), self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def sync_history repo_id
        begin
          response = get(Repository.repository_path + repo_id + "/sync/", self.default_headers)
          json_history = JSON.parse(response.body)
          json_history.collect {|jh| jh.with_indifferent_access }
        rescue RestClient::ResourceNotFound => error
          # Return nothing if there is a 404 which indicates there
          # is no sync status for this repo.  Not an error.
          return
        end
      end

      def cancel(repo_id, sync_id)
        path = Repository.repository_path + repo_id + "/sync/" + sync_id + "/"
        response = delete(path, self.default_headers)
        #JSON.parse(response.body).with_indifferent_access
      end

      def sync_status(repo_id, sync_id)
        path = Repository.repository_path + repo_id + "/sync/" + sync_id + "/"
        response = get(path, self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def destroy repo_id
        raise ArgumentError, "repository id has to be specified" unless repo_id
        path = Repository.repository_path + repo_id +"/"
        self.delete(path, self.default_headers).code.to_i
      end

      def packages repo_id
        response = get(repository_path  + repo_id + "/packages/", self.default_headers)
        body = response.body
        JSON.parse(body)
      end

      def errata repo_id
        response = get(repository_path  + repo_id + "/errata/", self.default_headers)
        body = response.body
        JSON.parse(body)
      end

      def distributions repo_id
        response = get(repository_path + repo_id + "/distribution/", self.default_headers)
        body = response.body
        JSON.parse(body)
      end

    end
  end

  class Consumer < PulpResource

    class << self
      
      def create key, uuid, description = "", key_value_pairs = {}
        url = consumer_path() + "?owner=#{key}"
        attrs = {:id => uuid, :description => description, :key_value_pairs => key_value_pairs}
        response = self.post(url, attrs.to_json, self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end
      
      def upload_package_profile uuid, package_profile
        attrs = {:id => uuid, :package_profile => package_profile}
        response = put(consumer_path(uuid) + "package_profile/", attrs.to_json, self.default_headers)
        raise RuntimeError, "failure from pulp" unless response
      end
      
      def update key, uuid, description = ""
        url = consumer_path(uuid) + "?owner=#{key}"
        attrs = {:id => uuid, :description => description}
        response = self.put(url, attrs.to_json, self.default_headers)
        raise RuntimeError, "failure from pulp" unless response
      end
      
      def find consumer_id
        response = get(consumer_path(consumer_id), self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def installed_packages consumer_id
        response = get(consumer_path(consumer_id) + "package_profile/", self.default_headers)
        JSON.parse(response.body)
      end

      def destroy consumer_id
        raise ArgumentError, "consumer_id id has to be specified" unless consumer_id
        self.delete(consumer_path(consumer_id), self.default_headers).code.to_i
      end

      def consumer_path id = nil
        url = "/pulp/api/consumers/#{id}"
        url = url + "/" if id
        url
      end

    end
  end

  class Task < PulpResource
    class << self
      def find uuid
        response = get(path  + uuid + "/", self.default_headers)
        body = response.body
        JSON.parse(body).with_indifferent_access
      end

      def path uuid=nil
        "/pulp/api/tasks/"
      end
    end
  end

end
