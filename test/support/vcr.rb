require "vcr"

module VCR
  def self.live?
    VCR.configuration.default_cassette_options[:record] != :none
  end

  def self.cassette_path
    "#{Katello::Engine.root}/test/fixtures/vcr_cassettes"
  end

end

def configure_vcr
  mode = ENV['mode'] ? ENV['mode'].to_sym : :none

  if ENV['record'] == "false" && mode == :none
    raise "Record flag is not applicable for mode 'none', please use with 'mode=all'"
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
    rescue => e
      #ignore the warning thrown about this matcher already being registered
    end

    begin
      c.register_request_matcher :params do |request_1, request_2|
        URI(request_1.uri).query == URI(request_2.uri).query
      end
    rescue => e
      #ignore the warning thrown about this matcher already being registered
    end

  end
end
