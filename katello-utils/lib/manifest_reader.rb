#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# Manifest representation in Ruby
#

require 'pp'
require 'rubygems'
require 'json'

# This class overrides the one from Katello core and it is responsible for
# fetching the CDN tree. It is similar to Resources::CDN:CdnResource but
# it is simplified (it does not load Katello settings and takes only few
# basic parameters).
#
class DisconnectedCdnResource
  attr_reader :url

  def initialize url, options = {}
    options.reverse_merge!(:verify_ssl => 9)
    options.assert_valid_keys(:ssl_client_key, :ssl_client_cert, :ssl_ca_file, :verify_ssl)

    @url = url
    @uri = URI.parse(@url)
    if options[:proxy_host]
      @net = ::Net::HTTP::Proxy(options[:proxy_host], oprions[:proxy_port], oprions[:proxy_user], oprions[:proxy_password]).new(@uri.host, @uri.port)
    else
      @net = ::Net::HTTP.new(@uri.host, @uri.port)
    end
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
          LOG.fatal "SSL verification failed -- preverify: #{preverify_ok}, error: #{ssl_context.error_string} (#{ssl_context.error})"
        end
        true
      end
    end
  end

  def get(path, headers={})
    path = File.join(@uri.request_uri,path)
    LOG.debug "Fetching info from #{path}"
    req = Net::HTTP::Get.new(path)
    begin
      @net.start do |http|
        res = http.request(req, nil) { |http_response| http_response.read_body }
        code = res.code.to_i
        if code == 200
          return res.body
        elsif code == 404
          LOG.fatal _("Resource %s not found") % File.join(url, path)
        elsif code == 403
          LOG.fatal _("Access denied to %s") % File.join(url, path)
        else
          LOG.fatal _("Server returned %s error") % code
        end
      end
    rescue EOFError
      LOG.fatal "Server broke connection"
    rescue Timeout::Error
      LOG.fatal "Server connection timeout"
    end
  end
end

module ManifestReader

  module StringToBool
    def to_bool
      return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
      return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)
      raise ArgumentError.new("invalid value for boolean: \"#{self}\"")
    end
  end

  class Consumer
    attr_accessor :uuid

    def initialize json_file
      c     = JSON.parse(IO.read json_file)
      @uuid = c['uuid']
    end

    def print_info
      puts "Consumer UUID: #{@uuid}"
    end
  end

  class Repository
    attr_accessor :basearch, :releasever, :path
    attr_reader :enabled
    attr_accessor :content

    def initialize basearch, releasever, enabled, path
      @basearch   = basearch
      @releasever = releasever
      @enabled    = "#{enabled}".extend(StringToBool).to_bool
      @path       = path
    end

    def enabled= value
      @enabled = "#{value}".extend(StringToBool).to_bool
    end

    # Return repoid in Pulp V2 friendly format (only alphanum, underscore or dash)
    def repoid
      "#{content.label}-#{releasever}-#{basearch}".gsub(/[^-\w]/,"_")
    end

    def repoid_enabled_hash
      { repoid => enabled }
    end

    def key
      content.product.entitlements.first.key
    end

    def cert
      content.product.entitlements.first.cert
    end

    def url
      File.join(content.product.manifest.cdn_url, path)
    end
  end

  class Content
    attr_accessor :product, :id, :name, :type, :url, :label, :gpg_url, :enabled

    def initialize product, pc_json
      @product      = product
      c             = pc_json["content"]
      @id           = c["id"]
      @name         = c["name"]
      @type         = c["type"]
      @url          = c["contentUrl"]
      @label        = c["label"]
      @gpg_url      = c["gpgUrl"]
      @enabled      = pc_json["enabled"]
      # empty until populate_repositories is called
      @repositories = {} # repoid -> Repository
    end

    def repositories
      @repositories.values
    end

    def print_info
      puts " - content #{name} (#{id})"
      puts "   - type: #{type}"
      puts "   - url: #{url}"
      puts "   - label: #{label}"
      puts "   - gpg_url: #{gpg_url}"
      puts "   - enabled: #{enabled}"
    end

    # add or replace repository
    def add_repository repo
      repo.content               = self
      @repositories[repo.repoid] = repo
    end

    def repoid_list
      repositories.collect { |r| r.repoid_enabled_hash }
    end

    def <=>(o)
      return name.<=>(o.name)
    end
  end

  class Product
    attr_accessor :manifest, :id, :name, :multi_entitlement
    attr_accessor :content
    attr_accessor :entitlements # in which this product belongs

    def initialize manifest, json_file
      @manifest          = manifest
      @entitlements      = []
      p                  = JSON.parse(IO.read json_file)
      #puts JSON.pretty_generate(p)
      @id                = p["id"]
      @name              = p["name"]
      @multi_entitlement = false
      p['attributes'].each do |a|
        @multi_entitlement = true if a['name'] == 'multi-entitlement' and a['value'].downcase == 'yes'
      end rescue @multi_entitlement = false
      pc       = p["productContent"]
      @content = {}
      pc.each do |pc|
        c              = Content.new(self, pc)
        @content[c.id] = c
      end
    end

    def print_info
      puts "Product #{name} (#{id})"
      puts "- multi_entitlement: #{multi_entitlement}"
      puts "Content:"
      content.each_value(&:print_info) if content
    end

    def <=>(o)
      return name.<=>(o.name)
    end
  end

  class Entitlement
    attr_accessor :manifest, :pool_id, :quantity, :end_date
    attr_accessor :contract_number, :account_number
    attr_accessor :primary_product_name, :primary_product_id, :primary_product, :primary_product
    attr_accessor :provided_product_ids, :provided_products
    attr_accessor :serial, :key, :cert, :pem_file

    def initialize manifest, json_file
      @manifest             = manifest
      e                     = JSON.parse(IO.read json_file)
      p                     = e["pool"]
      c                     = e["certificates"][0]
      @pool_id              = p["id"]
      @primary_product_name = p["productName"]
      @primary_product_id   = p["productId"]
      @quantity             = p["quantity"]
      @contract_number      = p["contractNumber"]
      @account_number       = p["accountNumber"]
      @end_date             = p["endDate"]
      @provided_product_ids = p["providedProducts"].collect { |pp| pp["productId"] }
      @serial               = c["serial"]["serial"]
      @key                  = c["key"]
      @cert                 = c["cert"]
    end

    def print_info
      puts "Entitlement (#{pool_id}):"
      puts "- primary product: #{primary_product_name} (#{primary_product_id})"
      puts "- quantity: #{quantity}"
      puts "- contract: #{contract_number}"
      puts "- account: #{account_number}"
      puts "- ends: #{end_date}"
      puts "- serial: #{serial}"
      puts "- pem file: #{pem_file}"
      puts "Provided products:"
      provided_products.each(&:print_info) if provided_products
    end

    def <=>(o)
      return pool_id.<=>(o.pool_id)
    end
  end

  class ConsumerType
    attr_accessor :id, :label

    def initialize json_file
      c      = JSON.parse(IO.read json_file)
      @id    = c["id"]
      @label = c["label"]
    end

    def print_info
      puts "Consumer Type: #{label} (#{id})"
    end
  end

  class Manifest
    attr_accessor :cdn_url, :cdn_ca
    attr_accessor :basedir, :version, :created
    attr_accessor :consumer, :products, :entitlements, :consumer_types

    def initialize manifest_file_or_directory, cdn_url = nil, cdn_ca = nil
      @cdn_url = cdn_url
      @cdn_ca  = cdn_ca
      if File.directory? manifest_file_or_directory
        basedir = manifest_file_or_directory
      else
        # prepare and unzip
        unless File.exist? manifest_file_or_directory
          puts "Unable to read file #{manifest_file_or_directory}"
          exit 2
        end
        basedir = `mktemp -d`.chomp
        at_exit do
          `rm -rf #{basedir}`
        end
        `unzip #{manifest_file_or_directory} -d #{basedir}`
        `unzip #{basedir}/consumer_export.zip -d #{basedir}`
      end

      # basic metadata about the export
      m         = JSON.parse(IO.read "#{basedir}/export/meta.json")
      @version  = m['version']
      @created  = m['created']

      # create hiearchy - consumer
      @consumer = Consumer.new "#{basedir}/export/consumer.json"

                     # products
      @products = {} # indexed by id
      Dir.glob("#{basedir}/export/products/*.json").each do |file|
        product               = Product.new(self, file)
        @products[product.id] = product
      end

                         # entitlements
      @entitlements = {} # indexed by pool_id
      Dir.glob("#{basedir}/export/entitlements/*.json").each do |file|
        entitlement                        = Entitlement.new(self, file)
        @entitlements[entitlement.pool_id] = entitlement
      end

      # consumer types
      @consumer_types = []
      Dir.glob("#{basedir}/export/consumer_types/*.json").each do |file|
        @consumer_types << ConsumerType.new(file)
      end

      # cross-reference
      @entitlements.each_value do |e|
        e.primary_product   = @products[e.primary_product_id]
        e.provided_products = e.provided_product_ids.collect { |ppi| @products[ppi] }
        e.provided_products.each { |p| p.entitlements << e }
        e.pem_file = "#{basedir}/export/entitlement_certificates/#{e.serial}.pem"
      end
    end

    def populate_repositories
      repo_counter = 0
      @entitlements.each_value do |entitlement|

        Rails.logger.debug "Processing entitlement #{entitlement.pool_id}"
        cdn_var_substitutor = Util::CdnVarSubstitutor.new(
          DisconnectedCdnResource.new(
            cdn_url,
            :ssl_ca_file => cdn_ca,
            :ssl_client_cert => OpenSSL::X509::Certificate.new(entitlement.cert),
            :ssl_client_key => OpenSSL::PKey::RSA.new(entitlement.key)))

        entitlement.provided_products.each do |product|
          Rails.logger.debug "Processing product #{product.name}"

          product.content.each_value do |content|
            Rails.logger.debug "Processing #{content.name} #{content.url}"

            cdn_var_substitutor.substitute_vars(content.url).each do |(substitutions, path)|
              arch = substitutions['basearch']
              ver  = substitutions['releasever']
              repo = Repository.new(arch, ver, content.enabled, path)
              content.add_repository repo
              repo_counter += 1
              # when called from disconnected script we want to print this in verbose
              if Rails.logger.respond_to? :verbose
                Rails.logger.verbose "Repository found: #{repo.repoid}"
              else
                Rails.logger.debug "Repository found: #{repo.repoid}"
              end
            end
          end
        end
      end
      repo_counter
    end

    # load manifest
    def self.load mf_filename, conf_filename = nil
      mf = File.open(mf_filename, "r") { |file| Marshal::load(file) }
      if conf_filename
        mf.load_repos_setting conf_filename
      end
      mf
    end

    def load_repos_setting filename
      repos = repositories
      IO.foreach(filename) do |line|
        begin
          if line !~ /^#.*/ and line =~ /^([^=]*)=(.*?)(\s*#.*)?$/
            repos[$1.strip].enabled = $2.strip.match(/(true|t|yes|y|1)$/i) if repos[$1.strip]
          end
        rescue Exception => e
          raise RuntimeError, "Error parsing #{$1}: #{e.message}"
        end
      end
    end

    # save manifest and create repos.conf template (with backup)
    def save mf_filename, conf_filename = nil
      File.open(mf_filename, "w") { |file| Marshal::dump(self, file) }
      if conf_filename
        save_repo_conf conf_filename, true
      end
    end

    def print_info
      puts "Manifest #{version} created #{created}"
      puts "\nPRODUCTS"
      @products.each_value(&:print_info)
      puts "\nENTITLEMENTS"
      @entitlements.each_value(&:print_info)
      puts "\nCONSUMER TYPES"
      @consumer_types.each(&:print_info)
      puts "\nCONSUMER"
      @consumer.print_info
      puts "\nREPOSITORIES"
      repositories.each_pair do |repoid, repo|
        puts "#{repoid} = #{repo.enabled} #{repo.object_id}"
      end
    end

    # hash of repoid => Repository
    def repositories
      return @repositories_hash if @repositories_hash
      @repositories_hash = {}
      @entitlements.each_value do |entitlement|
        entitlement.provided_products.each do |product|
          product.content.each_value do |content|
            content.repositories.each do |repo|
              @repositories_hash[repo.repoid] = repo
            end
          end
        end
      end
      @repositories_hash
    end

    def enable_repository repoid, enable = true
      repos = repositories
      if repos[repoid]
        repos[repoid].enabled = enable
      end
    end

    # list of enabled repoids
    def enabled_repositories
      repositories.reject { |k, v| !v.enabled }.keys.sort
    end

    def read_cdn_ca
      IO.read cdn_ca
    end

    def save_repo_conf filename, backup = nil
      if backup and File.exists? filename
        timestamp       = Time.now.strftime("%Y%m%d-%H%M%S")
        backup_filename = filename + "." + timestamp
        FileUtils.mv filename, backup_filename, :force => true
      end
      File.open(filename, "w") do |file|
        @entitlements.sort.each do |unused, entitlement|
          entitlement.provided_products.sort.each do |product|
            product.content.sort.each do |unused, content|
              file.puts "\n# #{content.name}"
              content.repositories.each do |repo|
                file.puts "#{repo.repoid}=#{repo.enabled}"
              end
            end
          end
        end
      end
    end
  end
end
