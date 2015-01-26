# rubocop:disable Lint/HandleExceptions
require "vcr"

module VCR
  def self.live?
    VCR.configuration.default_cassette_options[:record] != :none
  end

  def self.cassette_path
    "#{Katello::Engine.root}/test/fixtures/vcr_cassettes"
  end

  # test class that will automatically run each method in a cassette
  module TestCase
    extend ActiveSupport::Concern

    def vcr_matches
      [:method, :path, :params, :body_json]
    end

    def cassette_name
      test_name = self.__name__.downcase.gsub("test_", "")
      self_class = self.class.name.split("::")[-1].underscore.gsub("_test", "")
      class_path = self.class.name.split("::")[0...-1].map(&:underscore).join("/")
      "#{class_path}/#{self_class}/#{test_name}"
    end

    def run_with_vcr(args)
      VCR.insert_cassette(cassette_name, :match_requests_on => vcr_matches)
      to_ret = run_without_vcr(args)
      VCR.eject_cassette
      to_ret
    end

    included do
      alias_method_chain :run, :vcr
    end
  end
end

# rubocop:disable Metrics/MethodLength
def configure_vcr
  mode = ENV['mode'] ? ENV['mode'].to_sym : :none

  if ENV['record'] == "false" && mode == :none
    fail "Record flag is not applicable for mode 'none', please use with 'mode=all'"
  end

  if mode != :none
    system("sudo cp -rf #{Katello::Engine.root}/test/fixtures/test_repos /var/www/")
  end

  VCR.configure do |c|
    c.cassette_library_dir = VCR.cassette_path
    c.hook_into :webmock

    if ENV['record'] == "false" && mode != :none
      uri = URI.parse(Katello.config.pulp.url)
      c.ignore_hosts uri.host
    end

    c.default_cassette_options = {
      :record => mode,
      :decode_compressed_response => true,
      :match_requests_on => [:method, :path, :params, :body_json],
      :serialize_with => :syck
    }

    begin
      c.register_request_matcher :body_json do |request_1, request_2|
        begin
          json_1 = JSON.parse(request_1.body)
          json_2 = JSON.parse(request_2.body)

          json_1 == json_2
        rescue
          #fallback incase there is a JSON parse error
          request_1.body == request_2.body
        end
      end
    rescue
      #ignore the warning thrown about this matcher already being registered
    end

    begin
      c.register_request_matcher :params do |request_1, request_2|
        URI(request_1.uri).query == URI(request_2.uri).query
      end
    rescue
      #ignore the warning thrown about this matcher already being registered
    end
  end
end
