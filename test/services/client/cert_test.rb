#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest/autorun'
require File.expand_path('../../../../app/services/client/cert.rb', __FILE__)

module Client
  class CertTest < MiniTest::Unit::TestCase

    CERT = '
      -----BEGIN CERTIFICATE-----
      MIIEaTCCA1GgAwIBAgIIMAikOB+/HpowDQYJKoZIhvcNAQEFBQAwezELMAkGA1UE
      BhMCVVMxFzAVBgNVBAgTDk5vcnRoIENhcm9saW5hMRAwDgYDVQQHEwdSYWxlaWdo
      MRAwDgYDVQQKEwdTb21lT3JnMRQwEgYDVQQLEwtTb21lT3JnVW5pdDEZMBcGA1UE
      AxMQY2VudG9zLmluc3RhbGxlcjAeFw0xNDAzMTcxOTUwMjBaFw0zMDAzMTcxOTUw
      MjBaMC8xLTArBgNVBAMTJDE0ZTk4MTU1LTczMWEtNGNhZS1iMTUxLTVjNTA0Y2Mz
      MGUxYTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKlWUgos9daHOxCg
      rvRHzDBrScUVEYl+EzJADNiL0EXkKTzIlxxAU21QE0v0DyMjUGHZRQ6vwn+fX1rp
      v1xLO7wH5G/+hQKLS4amSHF2EzOpuuOBE1bBLmuvg28PttLQb3OUCO1O87g+5cE/
      EuX206zOcqs+9qcrOULrFyopaFpviA3F1C5R6AhNpOWerBvxtoLMfFFXL3MTj3d3
      XzmTMycvxAjyBs3elSZgrf+b0lF/OIxL7xlgzW7IZGSl4e2Lx6dRgyUj+4dyx4X4
      zkdhuj5Khnfvbut20BTyOVh/Y0uAAu4pm58B9PPIjxmkl03QPh0htMdtO/FRg3W8
      9QgsYDcCAwEAAaOCATswggE3MBEGCWCGSAGG+EIBAQQEAwIFoDALBgNVHQ8EBAMC
      BLAwga0GA1UdIwSBpTCBooAUkQeVYv8I+1JAExaABq5A/U3Fh7ahf6R9MHsxCzAJ
      BgNVBAYTAlVTMRcwFQYDVQQIEw5Ob3J0aCBDYXJvbGluYTEQMA4GA1UEBxMHUmFs
      ZWlnaDEQMA4GA1UEChMHU29tZU9yZzEUMBIGA1UECxMLU29tZU9yZ1VuaXQxGTAX
      BgNVBAMTEGNlbnRvcy5pbnN0YWxsZXKCCQCqejy74F8t8TAdBgNVHQ4EFgQUK7io
      wey/1DrRtCvzM/YgoyHbdQ0wEwYDVR0lBAwwCgYIKwYBBQUHAwIwMQYDVR0RBCow
      KKQmMCQxIjAgBgNVBAMMGWRoY3AxMjktNzQucmR1LnJlZGhhdC5jb20wDQYJKoZI
      hvcNAQEFBQADggEBAGYZWSCZsmpAJECW07q8FF8OgwLwQAqlPIO6wLtu9g5wL3c5
      Aw3TDHoFcxMe7hADcUvi+n2SzupS94NqY4F3FOBH6IjFAeZZUpQXjy7nG6jN8Agx
      n+iM9RXh+pmwxJtPWMq0gTbmBQvxcPxBHr6vFNKrXJm4WAKLihI4ErtgeKZMAFn7
      /gkhjiyicxw+uxRHuNyMClM8Q5WVj4CpxrPHwZvN1OhM8D3VDnEaZj6J2k5g55Fl
      3qQXsk8lPEJ2I5D00Up2cpDBy+CXj5zm/shmqEJlGOxILjpCzNhqER/YdBlGPP9b
      okjCBjwYlp5cNyAJSQscLF7rj/iOJYhRdetWMZg=
      -----END CERTIFICATE-----'

    def test_uuid
      rhsm_cert = Client::Cert.new(CERT)
      assert_equal rhsm_cert.uuid, '14e98155-731a-4cae-b151-5c504cc30e1a'
    end

    def test_empty_cert
      assert_raises RuntimeError do
        Cert.new('')
      end
    end

    def test_bad_cert
      assert_raises OpenSSL::X509::CertificateError do
        Cert.new('This is not a real cert string.')
      end
    end

  end
end
