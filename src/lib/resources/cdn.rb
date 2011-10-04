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
      options.assert_valid_keys(:ssl_client_cert, :ssl_ca_file, :verify_ssl)
      @resource = RestClient::Resource.new url, options
    end

    def get(path, headers={})
      @resource[path].get headers
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
      paths_with_vars = { {} => path_with_vars}
      paths_without_vars = {}

      while substitutions_and_path = paths_with_vars.shift
        substitutions, path = substitutions_and_path
        if path.include?("$")
          substitute_next_var(substitutions, path) do |new_substitution, new_path|
            paths_with_vars[new_substitution] = new_path
          end
        else
          paths_without_vars[substitutions] = path
        end
      end

      return paths_without_vars
    end

    def substitute_next_var(substitutions, path)
      if path =~ /^(.*?)\$([^\/]*)/
        base_path, var = $1, $2
        values = @resource.get(File.join(base_path,"listing")).split("\n")
        values.each do |value|
          yield substitutions.merge(var => value), path.sub("$#{var}",value)
        end
      end
    end
  end
end
