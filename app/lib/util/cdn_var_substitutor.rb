#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Util

  class CdnVarSubstitutor

    # cdn_resource - an object providing access to CDN. It has to
    # provide a get method that takes a path (e.g.
    # /content/rhel/6.2/listing) and returns the body response)
    def initialize(cdn_resource)
      @resource = cdn_resource
      @substitutions = Thread.current[:cdn_var_substitutor_cache] || {}
    end

    # using substitutor from whithin the block makes sure that every
    # request is made only once.
    def self.with_cache(&block)
      Thread.current[:cdn_var_substitutor_cache] = {}
      yield
    ensure
      Thread.current[:cdn_var_substitutor_cache] = nil
    end

    # precalcuclate all paths at once - let's you discover errors and stop
    # before it causes more pain
    def precalculate(paths_with_vars)
      paths_with_vars.uniq.reduce({}) do |ret, path_with_vars|
        ret[path_with_vars] = substitute_vars(path_with_vars); ret
      end
    end

    # takes path e.g. "/rhel/server/5/$releasever/$basearch/os"
    # returns hash substituting variables:
    #
    #  { {"releasever" => "6Server", "basearch" => "i386"} =>  "/rhel/server/5/6Server/i386/os",
    #    {"releasever" => "6Server", "basearch" => "x86_64"} =>  "/rhel/server/5/6Server/x84_64/os"}
    #
    # values are loaded from CDN
    def substitute_vars(path_with_vars)
      if path_with_vars =~ /^(.*\$\w+)(.*)$/
        prefix_with_vars, suffix_witout_vars =  $1, $2
      else
        prefix_with_vars, suffix_witout_vars = "", path_with_vars
      end

      prefixes_without_vars = substitute_vars_in_prefix(prefix_with_vars)
      paths_without_vars = prefixes_without_vars.reduce({}) do |h, (substitutions, prefix_without_vars)|
        h[substitutions] = prefix_without_vars + suffix_witout_vars; h
      end
      return paths_without_vars
    end

    # prefix_with_vars is the part of url containing some vars. We can cache
    # calcualted values for this parts. So for example for:
    #   "/a/$b/$c/d"
    #   "/a/$b/$c/e"
    # prefix_with_vars is "/a/$b/$c" and we store the result after resolving
    # for the first path.
    def substitute_vars_in_prefix(prefix_with_vars)
      paths_with_vars = { {} => prefix_with_vars}
      prefixes_without_vars = @substitutions[prefix_with_vars]

      unless prefixes_without_vars
        prefixes_without_vars = {}
        while not paths_with_vars.empty?
          substitutions, path = paths_with_vars.shift

          if is_substituable path
            for_each_substitute_of_next_var substitutions, path do |new_substitution, new_path|
              begin
                paths_with_vars[new_substitution] = new_path
              rescue Errors::SecurityViolation => e
                # Some paths may not be accessible
                @resource.log :warn, "#{new_path} is not accessible, ignoring"
              end
            end
          else
            prefixes_without_vars[substitutions] = path
          end
        end
        @substitutions[prefix_with_vars] = prefixes_without_vars
      end
      return prefixes_without_vars
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
        get_substitutions_from(base_path).compact.each do |value|

          new_substitutions = substitutions.merge(var => value)
          new_path = path.sub("$#{var}",value)

          yield new_substitutions, new_path
        end
      end
    end

    def get_substitutions_from(base_path)
      @resource.get(File.join(base_path,"listing")).split("\n")
    rescue Errors::NotFound => e # some of listing file points to not existing content
      @resource.log :error, e.message
      @resource.product.try(:repositories_cdn_import_failed!)
      [] # return no substitution for unreachable listings
    end

  end
end
