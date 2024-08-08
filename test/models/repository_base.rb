require 'katello_test_helper'

module Katello
  class RepositoryTestBase < ActiveSupport::TestCase
    def setup
      @acme_corporation                 = get_organization
      @fedora_root                      = katello_root_repositories(:fedora_17_x86_64_root)
      @rhel6_root                       = katello_root_repositories(:rhel_6_x86_64_root)
      @docker_root                      = katello_root_repositories(:busybox_root)
      @fedora_17_x86_64                 = katello_repositories(:fedora_17_x86_64)
      @fedora_17_x86_64_dev             = katello_repositories(:fedora_17_x86_64_dev)
      @fedora_17_library_library_view   = katello_repositories(:fedora_17_library_library_view)
      @fedora_17_dev_library_view       = katello_repositories(:fedora_17_dev_library_view)
      @redis                            = katello_repositories(:redis)
      @fedora                           = katello_products(:fedora)
      @library                          = katello_environments(:library)
      @dev                              = katello_environments(:dev)
      @staging                          = katello_environments(:staging)
      @unassigned_gpg_key               = katello_gpg_keys(:unassigned_gpg_key)
      @library_dev_staging_view         = katello_content_views(:library_dev_staging_view)
      @library_view                     = katello_content_views(:library_view)
      @admin                            = users(:admin)
    end

    # Returns a list of valid labels
    def valid_label_list
      [
        RFauxFactory.gen_alpha(1),
        RFauxFactory.gen_numeric_string(1),
        RFauxFactory.gen_alphanumeric(rand(2..127)),
        RFauxFactory.gen_alphanumeric(128),
        RFauxFactory.gen_alpha(rand(2..127)),
        RFauxFactory.gen_alpha(128),
      ]
    end

    # Returns a list of valid credentials for HTTP authentication
    def valid_http_credentials_list(escape = false)
      credentials = [
        { login: 'admin', pass: 'changeme', quote: false },
        { login: '@dmin', pass: 'changeme', quote: true },
        { login: 'adm/n', pass: 'changeme', quote: false },
        { login: 'admin2', 'pass': 'ch@ngeme', quote: true },
        { login: 'admin3', 'pass': 'chan:eme', quote: false },
        { login: 'admin4', 'pass': 'chan/eme', quote: true },
        { login: 'admin5', 'pass': 'ch@n:eme', quote: true },
        { login: '0', pass: 'mypassword', quote: false },
        { login: '0123456789012345678901234567890123456789', pass: 'changeme', quote: false },
        { login: 'admin', pass: '', quote: false },
        { login: '', pass: 'mypassword', quote: false },
        { login: '', pass: '', quote: false },
        { login: RFauxFactory.gen_alpha(rand(1..512)), pass: RFauxFactory.gen_alpha, quote: false },
        { login: RFauxFactory.gen_alphanumeric(rand(1..512)), pass: RFauxFactory.gen_alphanumeric, quote: false },
        { login: RFauxFactory.gen_utf8(rand(1..50)), pass: RFauxFactory.gen_utf8, quote: true },
      ]
      if escape
        credentials = credentials.map do |cred|
          { login: CGI.escape(cred[:login]), pass: CGI.escape(cred[:pass]), quote: cred[:quote] }
        end
      end
      credentials
    end

    # Returns a list of invalid credentials for HTTP authentication
    def invalid_http_credentials(escape = false)
      credentials = [
        { login: RFauxFactory.gen_alpha(1024), pass: '', string_type: :alpha },
        { login: RFauxFactory.gen_alpha(512), pass: RFauxFactory.gen_alpha(512), string_type: :alpha },
        { login: RFauxFactory.gen_utf8(512), pass: RFauxFactory.gen_utf8(512), string_type: :utf8 },
      ]
      if escape
        credentials = credentials.map do |cred|
          { login: CGI.escape(cred[:login]), pass: CGI.escape(cred[:pass])}
        end
      end
      credentials
    end
  end
end
