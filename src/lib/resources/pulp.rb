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

module Resources

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
      if AppConfig.pulp
        cfg = AppConfig.pulp
        url = cfg.url
        self.prefix = URI.parse(url).path
        self.site = url.gsub(self.prefix, "")
        self.consumer_secret = cfg.oauth_secret
        self.consumer_key = cfg.oauth_key
        self.ca_cert_file = cfg.ca_cert_file
      end


      def self.default_headers
        {'accept' => 'application/json',
         'accept-language' => I18n.locale,
         'content-type' => 'application/json'}.merge(::User.pulp_oauth_header)
      end

      # some old Pulp API need text/plain content type
      def self.default_headers_text
        h = self.default_headers
        h['content-type'] = 'text/plain'
        h
      end

      # the path is expected to have trailing slash
      def self.path_with_prefix path
        PulpResource.prefix + path
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
          response = get('/pulp/api/v2/users/', self.default_headers).body
          JSON.parse(response)
        end
      end
    end

    class Package < PulpResource

      class << self

        # Get all the Repositories known by Pulp
        def all
          search({})
        end

        def find(id)
          result = search("filters"=> {"_id"=> {"$in"=> [id]}})
          result.first.with_indifferent_access if result.first
        end

        def search(criteria)
          data = {
              :criteria=>criteria
          }
          response = post(package_path, JSON.generate(data), self.default_headers).body
          JSON.parse(response)
        end

        def name_search(name)
          pkgs = search("^" + name, true)
          pkgs.collect{|pkg| pkg["name"]}
        end

        def package_path
          PulpResource.prefix + '/content/units/rpm/search/'
        end

        def dep_solve pkgnames, repoids
          path = "/pulp/api/services/dependencies/"
          response = post(path, JSON.generate({:pkgnames=>pkgnames, :repoids=>repoids}),  self.default_headers)
          JSON.parse(response)
        end


      end
    end

    class Errata < PulpResource

      class << self
        def find(errata_id)
          result = search({
            :filters => {
                "id"=> {
                    "$in"=> [errata_id]
                }
            }
          })
          result.first
        end

        def search filter
          data = {
              :criteria => filter
          }
          response = post(errata_path, JSON.generate(data), self.default_headers)
          JSON.parse(response.body).collect{|e| e.with_indifferent_access}
        end

        def errata_path
          PulpResource.prefix + '/content/units/erratum/search/'
        end

        def filter(filter)
          path = "#{errata_path}?#{filter.to_param}"
          response = get(path, self.default_headers)
          JSON.parse(response.body).map(&:with_indifferent_access)
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
          "/pulp/api/distributions/"
        end
      end
    end


    #Importers should supply  id & config methods
    class Importer
      def initialize params={}
        params.each{|k,v| self.send("#{k.to_s}=",v)}
      end
    end

    class YumImporter < Importer
      #https://github.com/pulp/pulp/blob/master/rpm-support/plugins/importers/yum_importer/importer.py
      attr_accessor 'feed_url', 'ssl_verify', 'ssl_ca_cert', 'ssl_client_cert', 'ssl_client_key',
                        'proxy_url', 'proxy_port', 'proxy_pass', 'proxy_user',
                        'max_speed', 'verify_size', 'verify_checksum', 'num_threads',
                        'newest', 'remove_old', 'num_old_packages', 'purge_orphaned', 'skip', 'checksum_type',
                        'num_retries', 'retry_delay'

      def id
         'yum_importer'
      end

      def config
          self.as_json
      end
    end

    #distributors should supply  id & config methods
    class Distributor
      attr_accessor 'auto_publish', 'id'

      def initialize params={}
        @auto_publish = false
        id = SecureRandom.hex(10)
        params.each{|k,v| self.send("#{k.to_s}=",v)}
      end
    end

    class YumDistributor < Distributor
      #required
      attr_accessor "relative_url", "http", "https"
      #optional
      attr_accessor "protected", "auth_cert", "auth_ca",
                    "https_ca", "gpgkey", "generate_metadata",
                    "checksum_type", "skip", "https_publish_dir", "http_publish_dir"

      def initialize relative_url, http, https, params={}
        @relative_url=relative_url
        @http = http
        @https = https
        super(params)
      end

      def type_id
        'yum_distributor'
      end

      def config
        to_ret = self.as_json
        to_ret.delete('auto_publish')
        to_ret.delete('id')
        to_ret
      end
    end

    class Repository < PulpResource
      class << self

        def find repo_id, yell_on_404 = false
          response = get(repository_path  + repo_id + "/?details=true", self.default_headers)
          body = response.body
          JSON.parse(body).with_indifferent_access
        rescue RestClient::ResourceNotFound => e
          return nil if !yell_on_404
          raise e
        end

        def find_all repo_ids
          filter = {"criteria" => {
                      "filters"=> {"id"=> {"$in"=> repo_ids}}
                   }
                }
          response = post(repository_path  + "/search/", JSON.generate(filter) , self.default_headers)
          body = response.body
          JSON.parse(body).collect{|i| i.with_indifferent_access}
        end

        # Get all the Repositories known by Pulp
        # currently filtering against only one groupid is supported in PULP
        def all
          response = get(self.repository_path + "/?details=true" , self.default_headers)
          JSON.parse(response.body)
        rescue RestClient::ResourceNotFound => e
          raise e
        end

        def start_discovery url, type
          response = post("/pulp/api/services/discovery/repo/", JSON.generate(:url => url, :type => type), self.default_headers)
          return JSON.parse(response.body).with_indifferent_access if response.code == 202
          Rails.logger.error("Failed to start repository discovery. HTTP status: #{response.code}. #{response.body}")
          raise RuntimeError, "#{response.code}, failed to start repository discovery: #{response.body}"
        end

        def repository_path repo_id=nil
          "/pulp/api/v2/repositories/#{(repo_id + '/') if repo_id}"
        end

        # {:id, :display_name},  importer=nil,distributors=[]
        def create attrs, importer=nil, distributors=[]
          attrs.merge!({:importer_type_id=>importer.id, :importer_config=>importer.config}) if importer
          attrs.merge!({:distributors=>distributors.collect{|d| [d.type_id, d.config, d.auto_publish, d.id] }}) if !distributors.empty?
          body = post(Repository.repository_path, JSON.generate(attrs), self.default_headers).body
          JSON.parse(body).with_indifferent_access
        end

        def unit_copy src_repo_id, dest_repo_id, type_id=nil, filters=nil, override=nil
          body = {:source_repo_id=>src_repo_id}
          body[:criteria] = {}
          body[:criteria][:filters]=filters if filters
          body[:criteria][:type_ids] = [type_id] if type_id
          body[:override_config] = override if override
          response = post(self.repository_path(dest_repo_id) + '/actions/associate/', JSON.generate(body), self.default_headers)
          JSON.parse(response).with_indifferent_access
        end

        def package_copy src_repo_id, dest_repo_id, package_ids=[]
          filters = {
              #:unit=>
              'association' => {'unit_id' => {'$in' => package_ids }}
          }
          unit_copy src_repo_id, dest_repo_id, 'rpm', filters, {:resolve_dependencies=> true}
        end

        def errata_copy src_repo_id, dest_repo_id, errata_ids=[]
          filters = {
              :unit => {
                    :id=>{
                        '$in' => errata_ids
                    }
                }
          }
          unit_copy src_repo_id, dest_repo_id, 'erratum', filters, {:resolve_dependencies=> true}
        end

        def distribution_copy src_repo_id, dest_repo_id, dist_id
          filters = {
              'id' => {'$in' => dist_id }
          }
          unit_copy src_repo_id, dest_repo_id, 'distribution', filters, {:resolve_dependencies=> true}
        end

        # :id, :name
        def update repo_id, attrs
          body = put(Repository.repository_path + repo_id +"/", JSON.generate(attrs), self.default_headers).body
          find repo_id
        end

        def schedule_path repo_id, schedule_id=nil
          Repository.repository_path(repo_id) +
              "importers/yum_importer/sync_schedules/#{(schedule_id + '/') if schedule_id}"
        end

        def schedules(repo_id)
          body = get(Repository.schedule_path(repo_id), self.default_headers)
          JSON.parse(body)
        end

        def create_or_update_schedule(repo_id, schedule)
          schedules = Repository.schedules(repo_id)
          if schedules.empty?
            Repository.create_schedule(repo_id, schedule)
          else
            #just update the 1st since we only support 1
            Repository.update_schedule(repo_id, schedules[0]['_id'], schedule)
          end
        end

        def create_schedule(repo_id, schedule)
          body = post(Repository.schedule_path(repo_id), JSON.generate(:schedule => schedule), self.default_headers).body
        end

        # specific call to just update the sync schedule for a repo
        def update_schedule(repo_id, schedule_id, schedule)
          body = put(Repository.schedule_path(repo_id, schedule_id), JSON.generate(:schedule => schedule), self.default_headers).body
        end

        def delete_schedule(repo_id)
          schedules = Repository.schedules(repo_id)
          if !schedules.empty?
            body = self.delete(Repository.schedule_path(repo_id) +"/importers/yum_importer/sync_schedules/", self.default_headers).body
          end
        end

        def add_packages repo_id, pkg_id_list
          body = post(Repository.repository_path + repo_id +"/add_package/", {:packageid=>pkg_id_list}.to_json, self.default_headers).body
        end

        def add_errata repo_id, errata_id_list
          body = post(Repository.repository_path + repo_id +"/add_errata/", {:errataid=>errata_id_list}.to_json, self.default_headers).body
        end

        def add_distribution repo_id, distribution_id
          body = post(Repository.repository_path + repo_id +"/add_distribution/", {:distributionid=>distribution_id}.to_json, self.default_headers).body
        end

        def sync (repo_id, data = {})
          data[:max_speed] ||= AppConfig.pulp.sync_KBlimit if AppConfig.pulp.sync_KBlimit # set bandwidth limit
          data[:num_threads] ||= AppConfig.pulp.sync_threads if AppConfig.pulp.sync_threads # set threads per sync
          path = Repository.repository_path + repo_id + "/actions/sync/"
          response = post(path, JSON.generate(data), self.default_headers)
          #TODO Properly use both the sync and publish tasks
          JSON.parse(response.body).select{|i| i['tags'].include?("pulp:action:sync")}.first.with_indifferent_access
        end

        def sync_history repo_id
          begin
            #
            body = get(repository_path(repo_id) + '/history/sync/', self.default_headers).body
            JSON.parse(body).collect{|i| i.with_indifferent_access}
          rescue RestClient::ResourceNotFound => error
            # Return nothing if there is a 404 which indicates there
            # is no sync status for this repo.  Not an error.
            return
          end
        end

        def sync_status(repo_id)
          response = Task.all(["pulp:repository:#{repo_id}", "pulp:action:sync"])
          return response
        end


        def destroy repo_id
          raise ArgumentError, "repository id has to be specified" unless repo_id
          path = Repository.repository_path + repo_id +"/"
          self.delete(path, self.default_headers).code.to_i
        end

        def packages repo_id
          criteria = {:type_ids=>['rpm'],
                  :sort => {
                      :unit => [ ['name', 'ascending'], ['version', 'descending'] ]
                  }}
          package_unit_search(repo_id, criteria)
        end

        def packages_by_nvre(repo_id, name, version=nil, release=nil, epoch=nil)
          and_condition = []
          and_condition << {:name=>name} if name
          and_condition << {:version=>version} if version
          and_condition << {:release=>release} if release
          and_condition << {:epoch=>epoch} if epoch

          criteria = {:type_ids=>['rpm'],
                  :filters => {
                      :unit => {
                        "$and" => and_condition
                      }
                  },
                  :sort => {
                      :unit => [ ['name', 'ascending'], ['version', 'descending'] ]
                  }}
          package_unit_search(repo_id, criteria)
        end

        def errata(repo_id, filter = {})
          data = { :criteria => {
                    :type_ids=>['erratum'],
                    :sort => {
                        :unit => [ ['title', 'ascending'] ]
                    }
                   }
                  }
          response = post(repository_path(repo_id) + 'search/units/', JSON.generate(data), self.default_headers)
          JSON.parse(response.body).collect{|i| i['metadata'].with_indifferent_access}
        end

        def distributions(repo_id)
          response = get(repository_path + repo_id + "/distribution/", self.default_headers)
          body = response.body
          JSON.parse(body)
        end

        def add_filters repo_id, filter_ids
          response =  post(repository_path + repo_id + "/add_filters/", {:filters => filter_ids}.to_json, self.default_headers)
          response.body
        end

        def remove_filters repo_id, filter_ids
          response =  post(repository_path + repo_id + "/remove_filters/", {:filters => filter_ids}.to_json, self.default_headers)
          response.body
        end

        def publish repo_id
          data = {
              :id=>find(repo_id)['distributors'].first()['id']
          }
          response = post(repository_path(repo_id) + "actions/publish/", JSON.generate(data), self.default_headers)
          JSON.parse(response.body).with_indifferent_access
        end

        def generate_metadata repo_id
          response = post(repository_path + repo_id + "/generate_metadata/", {}, self.default_headers)
          JSON.parse(response.body).with_indifferent_access
        end

        private

        def package_unit_search repo_id, criteria,
          data = { :criteria => criteria }
          response = post(repository_path(repo_id) + 'search/units/', JSON.generate(data), self.default_headers)
          body = response.body
          JSON.parse(body).collect{|e| e['metadata'].with_indifferent_access}
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
          raise RuntimeError, "update failed" unless response
          return response
        end

        def update key, uuid, description = ""
          url = consumer_path(uuid) + "?owner=#{key}"
          attrs = {:id => uuid, :description => description}
          response = self.put(url, attrs.to_json, self.default_headers)
          raise RuntimeError, "update failed" unless response
          return response
        end

        def find consumer_id
          response = get(consumer_path(consumer_id), self.default_headers)
          JSON.parse(response.body).with_indifferent_access
        end

        def installed_packages consumer_id
          response = get(consumer_path(consumer_id) + "package_profile/", self.default_headers)
          JSON.parse(response.body)
        end

        def install_packages consumer_id, package_names
          url = consumer_path(consumer_id) + "installpackages/"
          attrs = {:packagenames => package_names}
          response = self.post(url, attrs.to_json, self.default_headers)
          JSON.parse(response.body).with_indifferent_access
        end

        def uninstall_packages consumer_id, package_names
          url = consumer_path(consumer_id) + "uninstallpackages/"
          attrs = {:packagenames => package_names}
          response = self.post(url, attrs.to_json, self.default_headers)
          JSON.parse(response.body).with_indifferent_access
        end

        def update_packages consumer_id, package_names
          url = consumer_path(consumer_id) + "updatepackages/"
          attrs = {:packagenames => package_names}
          response = self.post(url, attrs.to_json, self.default_headers)
          JSON.parse(response.body).with_indifferent_access
        end

        def install_package_groups consumer_id, package_groups
          url = consumer_path(consumer_id) + "installpackagegroups/"
          attrs = {:groupids => package_groups}
          response = self.post(url, attrs.to_json, self.default_headers)
          JSON.parse(response.body).with_indifferent_access
        end

        def uninstall_package_groups consumer_id, package_groups
          url = consumer_path(consumer_id) + "uninstallpackagegroups/"
          attrs = {:groupids => package_groups}
          response = self.post(url, attrs.to_json, self.default_headers)
          JSON.parse(response.body).with_indifferent_access
        end

        def destroy consumer_id
          raise ArgumentError, "consumer_id id has to be specified" unless consumer_id
          self.delete(consumer_path(consumer_id), self.default_headers).code.to_i
        end

        def errata consumer_id
          response = get(consumer_path(consumer_id) + "errata/", self.default_headers)
          JSON.parse(response.body)
        end

        def errata_by_consumer repos
          repoids_param = nil
          repos.each do |repo|
            if repoids_param.nil?
              repoids_param = "?repoids=" + repo.pulp_id
            else
              repoids_param += "&repoids=" + repo.pulp_id
            end
          end

          url = consumer_path() + "applicable_errata_in_repos/" + repoids_param
          response = get(url, self.default_headers)
          JSON.parse(response.body)
        end

        def install_errata consumer_id, errata_ids
          url = consumer_path(consumer_id) + "installerrata/"
          attrs = { :errataids => errata_ids }
          response = self.post(url, attrs.to_json, self.default_headers)
          JSON.parse(response.body).with_indifferent_access
        end

        def repoids consumer_id
          response = get(consumer_path(consumer_id) + "repoids/", self.default_headers)
          JSON.parse(response.body)
        end

        def bind uuid, repoid
          url = consumer_path(uuid) + "bind/"
          # this is old-style Pulp API call
          response = self.post(url, '"' + repoid + '"', self.default_headers_text)
          response.body
        end

        def unbind uuid, repoid
          url = consumer_path(uuid) + "unbind/"
          # this is old-style Pulp API call
          response = self.post(url, '"' + repoid + '"', self.default_headers_text)
          response.body
        end

        def consumer_path id = nil
          id.nil? ? "/pulp/api/consumers/" : "/pulp/api/consumers/#{id}/"
        end
      end
    end

    class Task < PulpResource
      class << self
        def find uuids
          ids = "id=#{uuids.join('&id=')}"
          query_url = path  + "?state=archived&state=current&#{ids}"
          response = self.get(query_url, self.default_headers)
          body = response.body
          JSON.parse(body).collect{|k| k.with_indifferent_access}
        end

        def find_single id
          body = self.get(path(id), self.default_headers).body
          JSON.parse(body).with_indifferent_access
        end

        def all tags=[]
          if tags.empty?
            args = ''
          else
            args = "/?tag=#{tags[0]}"
            tags[1..-1].each{|t| args += "&tag=#{t}"}
          end
          body = self.get(path + args, self.default_headers).body
          JSON.parse(body).collect{|k| k.with_indifferent_access}
        end

        def cancel uuid
          task = Task.find_single(uuid)
          self.delete(task['_href'], self.default_headers) if task
        end

        def destroy uuid
          response = self.delete(path(uuid), self.default_headers)
          JSON.parse(response.body).with_indifferent_access
        end

        def path uuid=nil
          uuid.nil? ? "/pulp/api/v2/tasks/" : "/pulp/api/v2/tasks/#{uuid}/"
        end

      end
    end

    class PackageGroup < PulpResource
      class << self
        def all repo_id
          response = get path(repo_id), self.default_headers
          JSON.parse(response.body).with_indifferent_access
        end

        def path repo_id
          self.path_with_prefix("/repositories/#{repo_id}/packagegroups/")
        end
      end
    end

    class PackageGroupCategory < PulpResource
      class << self
        def all repo_id
          response = get path(repo_id), self.default_headers
          JSON.parse(response.body).with_indifferent_access
        end

        def path repo_id
          self.path_with_prefix("/repositories/#{repo_id}/packagegroupcategories/")
        end
      end
    end

    class User < PulpResource
      class << self
        def create attrs
          response = self.post path, attrs.to_json, self.default_headers
          JSON.parse(response.body).with_indifferent_access
        end

        def destroy login
          self.delete(path(login), self.default_headers).code.to_i
        end

        def find login
          response = self.get path(login), self.default_headers
          JSON.parse(response.body).with_indifferent_access
        end

        def path(login=nil)
          users = self.path_with_prefix("/users/")
          login.nil? ? users : users + "#{login}/"
        end
      end
    end

    class Roles < PulpResource
      class << self
        def add role_name, username
          #/pulp/api/v2/roles/<role_id>/users/
          added = self.post(path(role_name) + "/users/", {:login => username}.to_json, self.default_headers)
          added.body == "true"
        end

        def remove role_name, username
          #/pulp/api/v2/roles/<role_id>/users/<user_login>
          removed = self.delete(path(role_name) + "/users/#{username}/",  self.default_headers)
          removed.body == "true"
        end

        def path(role_name=nil)
          roles = self.path_with_prefix("/roles/")
          roles += "#{role_name}/" if role_name
        end
      end
    end

  class ConsumerGroup < PulpResource
    class << self
      def create attrs
        response = self.post path, attrs.to_json, self.default_headers
        JSON.parse(response.body).with_indifferent_access
      end

      def destroy id
        self.delete(path(id), self.default_headers).code.to_i
      end

      def find id
        response = self.get path(id), self.default_headers
        JSON.parse(response.body).with_indifferent_access
      end

      def add_consumer id, consumer_id
        self.post "#{path(id)}add_consumer/", consumer_id.to_json, self.default_headers
      end

      def delete_consumer id, consumer_id
        self.post "#{path(id)}delete_consumer/", consumer_id.to_json, self.default_headers
      end

      def install_packages id, package_names
        url = path(id) + "installpackages/"
        attrs = {:packagenames => package_names}
        response = self.post(url, attrs.to_json, self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def uninstall_packages id, package_names
        url = path(id) + "uninstallpackages/"
        attrs = {:packagenames => package_names}
        response = self.post(url, attrs.to_json, self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def update_packages id, package_names
        url = path(id) + "updatepackages/"
        attrs = {:packagenames => package_names}
        response = self.post(url, attrs.to_json, self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def install_package_groups id, package_groups
        url = path(id) + "installpackagegroups/"
        attrs = {:grpids => package_groups}
        response = self.post(url, attrs.to_json, self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def uninstall_package_groups id, package_groups
        url = path(id) + "uninstallpackagegroups/"
        attrs = {:grpids => package_groups}
        response = self.post(url, attrs.to_json, self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def install_errata id, errata_ids
        url = path(id) + "installerrata/"
        attrs = { :errataids => errata_ids }
        response = self.post(url, attrs.to_json, self.default_headers)
        JSON.parse(response.body).with_indifferent_access
      end

      def path(id=nil)
        groups = self.path_with_prefix("/consumergroups/")
        id.nil? ? groups : groups + "#{id}/"
      end
    end
  end

    class Filter < PulpResource
      class << self
        def create attrs
          response = self.post path, attrs.to_json, self.default_headers
          JSON.parse(response.body).with_indifferent_access
        end

        def destroy id
          self.delete(path(id), self.default_headers).code.to_i
        end

        def find id
          response = self.get path(id), self.default_headers
          JSON.parse(response.body).with_indifferent_access
        end

        def add_packages id, packages
          response = self.post path(id) + "add_packages/", {:packages => packages}.to_json, self.default_headers
          return response.body
        end

        def remove_packages id, packages
          response = self.post path(id) + "remove_packages/", {:packages => packages}.to_json, self.default_headers
          return response.body
        end

        def path(id=nil)
          filters = self.path_with_prefix("/filters/")
          id.nil? ? filters : filters + "#{id}/"
        end
      end
    end

  end
end
