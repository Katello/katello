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

  module CDN

    class Utils

      # takes releasever from contentUrl (e.g. 6Server, 6.0, 6.1)
      # returns hash e.g. {:major => 6, :minor => "6.1"}
      # used to be able to make hierarchial view for RH repos
      def self.parse_version(releasever)
        if releasever.to_s =~ /^\d/
          {:major => releasever[/^\d+/].to_i, :minor => releasever }
        else
          {}
        end
      end
    end

    class CdnResource
      attr_reader :url
      attr_accessor :proxy_host, :proxy_port, :proxy_user, :proxy_password

      def initialize url, options = {}
        options.reverse_merge!(:verify_ssl => 9)
        options.assert_valid_keys(:ssl_client_key, :ssl_client_cert, :ssl_ca_file, :verify_ssl)
        if options[:ssl_client_cert]
          options.reverse_merge!(:ssl_ca_file => CdnResource.ca_file)
        end
        load_proxy_settings

        @url = url
        @uri = URI.parse(url)
        @net = net_http_class.new(@uri.host, @uri.port)
        @net.use_ssl = @uri.is_a?(URI::HTTPS)

        @net.cert = options[:ssl_client_cert]
        @net.key = options[:ssl_client_key]
        @net.ca_file = options[:ssl_ca_file]

        if (options[:verify_ssl] == false) || (options[:verify_ssl] == OpenSSL::SSL::VERIFY_NONE)
          @net.verify_mode = OpenSSL::SSL::VERIFY_NONE
        elsif options[:verify_ssl].is_a? Integer
          @net.verify_mode = options[:verify_ssl]
          @net.verify_callback = lambda do |preverify_ok, ssl_context|
            if (!preverify_ok) || ssl_context.error != 0
              err_msg = "SSL Verification failed -- Preverify: #{preverify_ok}, Error: #{ssl_context.error_string} (#{ssl_context.error})"
              raise RestClient::SSLCertificateNotVerified.new(err_msg)
            end
            true
          end
        end
      end

      def get(path, headers={})
        path = File.join(@uri.request_uri,path)
        Rails.logger.debug "CDN: Requesting path #{path}"
        req = Net::HTTP::Get.new(path)
        begin
          @net.start do |http|
            res = http.request(req, nil) { |http_response| http_response.read_body }
            code = res.code.to_i
            if code == 200
              return res.body
            else
              # we don't really use RestClient here (it doesn't allow to safely
              # set the proxy only for a set of requests and we don't want the
              # backend engines communication to go through the same proxy like
              # accessing CDN - its another use case)
              # But RestClient exceptions are really nice and can be handled in
              # the same way
              exception_class = RestClient::Exceptions::EXCEPTIONS_MAP[code] || RestClient::RequestFailed
              raise exception_class.new(nil, code)
            end
          end
        rescue EOFError
          raise RestClient::ServerBrokeConnection
        rescue Timeout::Error
          raise RestClient::RequestTimeout
        rescue RestClient::ResourceNotFound
          raise Errors::NotFound.new(_("CDN loading error: %s not found") % File.join(url, path))
        rescue RestClient::Unauthorized, RestClient::Forbidden
          raise Errors::SecurityViolation.new(_("CDN loading error: access denied to %s") % File.join(url, path))
        end
      end

      def self.ca_file
        "#{Rails.root}/ca/redhat-uep.pem"
      end

      def net_http_class
        if proxy_host
          Net::HTTP::Proxy(proxy_host, proxy_port, proxy_user, proxy_password)
        else
          Net::HTTP
        end
      end

      def load_proxy_settings
        if AppConfig.cdn_proxy && AppConfig.cdn_proxy.host
          self.proxy_host = parse_host(AppConfig.cdn_proxy.host)
          self.proxy_port = AppConfig.cdn_proxy.port
          self.proxy_user = AppConfig.cdn_proxy.user
          self.proxy_password = AppConfig.cdn_proxy.password
        end
      rescue URI::Error => e
        Rails.logger.error "Could not parse cdn_proxy:"
        Rails.logger.error e.to_s
      end

      def parse_host(host_or_url)
        uri = URI.parse(host_or_url)
        return uri.host || uri.path
      end

   end

    class CdnVarSubstitutor
      def initialize url, options
        @url = url
        @options = options
        @resource = CdnResource.new(@url, @options)
        @substitutions = Thread.current[:cdn_var_substitutor_cache] || {}
      end

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
                paths_with_vars[new_substitution] = new_path
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
end
