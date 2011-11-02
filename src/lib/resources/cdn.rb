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

require 'rest_client'
require 'http_resource'

module CDN

  class CdnResource
    attr_reader :url

    def initialize url, options = {}
      options.reverse_merge!(:verify_ssl => 9)
      options.assert_valid_keys(:ssl_client_key, :ssl_client_cert, :ssl_ca_file, :verify_ssl)
      if options[:ssl_client_cert]
        options.reverse_merge!(:ssl_ca_file => CdnResource.ca_file)
      end
      @resource = RestClient::Resource.new url, options
    end

    def get(path, headers={})
      @resource[path].get headers
    end

    def self.ca_file
      "#{Rails.root}/ca/redhat-uep.pem"
    end

 end

  class CdnVarSubstitutor
    def initialize url, options
      @url = url
      @options = options
      @resource = CdnResource.new(@url, @options)
    end

  # takes path e.g. "/rhel/server/5/$releasever/$basearch/os"
  # returns hash substituting variables:
  #
  #   { {"releasever" => "6Server", "basearch" => "i386"} =>  "/rhel/server/5/6Server/i386/os",
  #     {"releasever" => "6Server", "basearch" => "x86_64"} =>  "/rhel/server/5/6Server/x84_64/os"}
  #
  # values are loaded from CDN
    def substitute_vars(path_with_vars)
      paths_with_vars    = { {} => path_with_vars}
      paths_without_vars = {}

      while not paths_with_vars.empty?
        substitutions, path = paths_with_vars.shift

        if is_substituable path
          for_each_substitute_of_next_var substitutions, path do |new_substitution, new_path|
            paths_with_vars[new_substitution] = new_path
          end
        else
          paths_without_vars[substitutions] = path
        end
      end

      return paths_without_vars
    end

    def is_substituable path
      path.include?("$")
    end

    def is_substitute_of(substituted_url, original_url)
      substitutions = self.substitute_vars(original_url).values
      substitutions.include? substituted_url
    end

    protected

    def for_each_substitute_of_next_var(substitutions, path)
      if path =~ /^(.*?)\$([^\/]*)/
        base_path, var = $1, $2
        get_substitutions_from(base_path).each do |value|

          new_substitutions = substitutions.merge(var => value)
          new_path = path.sub("$#{var}",value)

          yield new_substitutions, new_path
        end
      end
    end

    def get_substitutions_from(base_path)
      @resource.get(File.join(base_path,"listing")).split("\n")
    end

  end
end
