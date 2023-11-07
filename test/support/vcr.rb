require "vcr"
require "active_support/concern"

WebMock.allow_net_connect!

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

    module Overrides
      def run
        SETTINGS[:katello][:use_pulp_2_for_content_type] = {}

        value = nil
        remove_cassette if VCR.live?
        VCR.use_cassette(cassette_name, :match_requests_on => vcr_matches) do
          value = super
        end
        value
      end
    end

    def vcr_matches
      [:method, :path, :params, :body_json]
    end

    def remove_cassette
      File.delete(cassette_file) if File.exist?(cassette_file)
    end

    def cassette_file
      File.join(VCR.cassette_path, cassette_name + '.yml')
    end

    def cassette_name
      test_name = self.method_name.downcase.gsub("test_", "").gsub(/[^0-9a-z ]/i, '_')
      self_class = self.class.name.split("::")[-1].underscore.gsub("_test", "")
      class_path = self.class.name.split("::")[0...-1].map(&:underscore).join("/")
      "#{class_path}/#{self_class}/#{test_name}"
    end

    included do
      prepend Overrides
    end
  end
end

def ignore_pending_tasks(request, response)
  return false unless request.uri.include?('/tasks/')
  body = JSON.parse(response.body) rescue nil
  finish_states = Katello::Pulp3::Task::FINISHED_STATES
  body.is_a?(Hash) && body['state'].present? && !finish_states.include?(body['state'])
end

# rubocop:disable Metrics/MethodLength
def configure_vcr
  mode = ENV['mode'] ? ENV['mode'].to_sym : :none

  if ENV['record'] == "false" && mode == :none
    fail "Record flag is not applicable for mode 'none', please use with 'mode=all'"
  end

  if mode != :none
    system("sudo cp -rf #{Katello::Engine.root}/test/fixtures/test_repos /var/lib/pulp/sync_imports/")
    system("sudo chown -R pulp:pulp /var/lib/pulp/sync_imports/")
  end

  VCR.configure do |c|
    c.cassette_library_dir = VCR.cassette_path
    c.hook_into :webmock
    c.before_record do |i|
      if ignore_pending_tasks(i.request, i.response)
        i.ignore!
      end
    end

    c.default_cassette_options = {
      :record => mode,
      :decode_compressed_response => true,
      :match_requests_on => [:method, :path, :params, :body_json],
      :serialize_with => :psych,
      :preserve_exact_body_bytes => true
    }

    begin
      c.register_request_matcher :body_json do |request_1, request_2|
        json_1 = JSON.parse(request_1.body)
        json_2 = JSON.parse(request_2.body)

        json_1 == json_2
      rescue
        #fallback incase there is a JSON parse error
        request_1.body == request_2.body
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
