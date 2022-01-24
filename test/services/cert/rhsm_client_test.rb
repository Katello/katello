require 'minitest/autorun'
require "katello_test_helper"
require File.expand_path("#{Katello::Engine.root}/app/services/cert/rhsm_client.rb", __FILE__)

module Katello
  class RhsmClientTest < Minitest::Test
    # Subject of old cert is
    # Subject: CN = 14e98155-731a-4cae-b151-5c504cc30e1a
    OLD_CERT = '
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
      -----END CERTIFICATE-----'.freeze

    # Subject of new cert is
    # Subject: O=Default_Organization, CN=eb48d5a8-b759-417c-97f7-93dc2369de29
    NEW_CERT = '
      -----BEGIN CERTIFICATE-----
    MIIGjDCCBHSgAwIBAgIIabvFmF/tIwkwDQYJKoZIhvcNAQELBQAwgZcxCzAJBgNV
    BAYTAlVTMRcwFQYDVQQIDA5Ob3J0aCBDYXJvbGluYTEQMA4GA1UEBwwHUmFsZWln
    aDEQMA4GA1UECgwHS2F0ZWxsbzEUMBIGA1UECwwLU29tZU9yZ1VuaXQxNTAzBgNV
    BAMMLGNlbnRvczcta2F0ZWxsby1jYW5kbGVwaW4uYXJlYTUyLmV4YW1wbGUuY29t
    MB4XDTIyMDEyMDIwMTIwNVoXDTM4MDEyMDIxMTIwNVowTjEdMBsGA1UECgwURGVm
    YXVsdF9Pcmdhbml6YXRpb24xLTArBgNVBAMMJDU3YjI2Y2UzLWU0ZmUtNGY3OS1h
    Mzc3LTJjNGQ5ZGVhNTIwNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
    ALikZKO/50yG6qcWkSIr6IzPT8ohENEro6TERhWMCAuwikHE+MKdhPpyUIOkdt56
    GXRU2zGhuxP4o+uG4B6r1EtG6Apvy5J6asL+pXHIUEvLG4HQmNQp8AqztAmS/Fh+
    5j6n2PyD7/iF5Moozf7Ew+HJJvjy+RPHin3EEm3QvWcG65/5HGQHF2F9vUfo2kAE
    ENhum2RLJ0EYZqBz7FkkBzS+onkY/uwmuRkxm0v4sHdQk1Fe5tLnBBm6pFDZzswB
    v134Gi/j6I865i9FvvPvxrOE+MsBW/x1JAwj54IMa2HDINQmAY8jWWyiPGUY5yLl
    kwnJ/CUBs+6qqKoUt+8H4TpC9dHStEdf2u1+nm+MgjRLm07piWo/Qp/bDh1OwfBT
    bsRl2riE/wSofjex6X8ZjRxImhWNjxvzJAn/VD6p5+rpxFDu5RjCoKsGF9Tbn5Vr
    /QRsfuiy9kwrsQYfp3tBAgyKsblTUncCT4KMTtVDbIm8MxlTLIDCjPRxLwhB1yan
    05FuYHMHAMKkH6NCypuGA4YF1XSPMgO6SfBLz61yoAqMEXT9ugkj7gFt8bFzMmVn
    b2BXNBXnC13oWG+EPd3THTeFEIZpbljZvGciqXTCKBnWD3tNcQx+ZQEbmhfNiwMg
    hVv6lonLbPat4zK3JkW920/Vc+rfdoPRbxImsjMKh24BAgMBAAGjggEiMIIBHjAO
    BgNVHQ8BAf8EBAMCBLAwEwYDVR0lBAwwCgYIKwYBBQUHAwIwCQYDVR0TBAIwADAR
    BglghkgBhvhCAQEEBAMCBaAwHQYDVR0OBBYEFOx+heEao9Xx+vY/e3ozUT2FeM3i
    MB8GA1UdIwQYMBaAFBnHeIYJrfaf8/3O44D+GvLA2Pc3MIGYBgNVHREEgZAwgY2k
    UDBOMR0wGwYDVQQKDBREZWZhdWx0X09yZ2FuaXphdGlvbjEtMCsGA1UEAwwkNTdi
    MjZjZTMtZTRmZS00Zjc5LWEzNzctMmM0ZDlkZWE1MjA0pDkwNzE1MDMGA1UEAwws
    Y2VudG9zNy1rYXRlbGxvLWNhbmRsZXBpbi5hcmVhNTIuZXhhbXBsZS5jb20wDQYJ
    KoZIhvcNAQELBQADggIBAAirOKFelb8FqTa6aaFb7JA7A3bQw7gjCDgaLiWF2KrT
    RUa1ayHQJ+Tm5jJPo9RNLzDnpKNjVFDK/E9zB8tcOTg8dZoeCvQ6FvjbRTi/8MWP
    Be5m3ef64a8tQxhdJPeMkRAjKnUzsGZbBjttZue3B89XisKytssk1tkXnY62V42Z
    m5aAiUfkTr/jeZkuZyLI9uF7Np4rws44/XmoEJp/LNWKmCTtvgIR6NP1W+J2LA/g
    LOIDLNTyy8Ju95ZDdNQ8KJC+Hrb+OiL86SvwHK9gTAqNqbKmFmQkAtpsgmcObRZF
    tQRzaHPwR+Pj1wmIoi6UMbeUKuPbVYRf2qVPtvtqFAIGhVBobmIHSE1+G2as0zqZ
    4LkssrjsyRR02K2aoIOl6IB0s1U2vZ8SRUI4HabSYX/rw9iEdWO1f/gD76YBxSxF
    5d/rtZUAUQEgS1hdrPlzeNsG5H8Mf05lJMghH8GFJfjkqm6OHkGYcJGCns1Mpai0
    4RS8QEA83rtEmSdY/oubjNGUMeXk0mjkOrSIblSUYixJJYdi+66IjePyCGMRhtd4
    0TV5WB3ONylUv777yuHRICFZyny63C1vtUIZMGtu67qYjKk4uMKnHC5lWMaSmepG
    ifSe+u12fpxjD0UirYSMj38vDtCbcFSPcAAu/1YKw4uvN5zcv+YI91tjOkMJuVah
    -----END CERTIFICATE-----'.freeze

    def test_uuid
      rhsm_cert_old = ::Cert::RhsmClient.new(OLD_CERT)
      rhsm_cert_new = ::Cert::RhsmClient.new(NEW_CERT)
      assert_equal rhsm_cert_old.uuid, '14e98155-731a-4cae-b151-5c504cc30e1a'
      assert_equal rhsm_cert_new.uuid, '57b26ce3-e4fe-4f79-a377-2c4d9dea5204'
    end

    def test_empty_cert
      assert_raises RuntimeError do
        ::Cert::RhsmClient.new('')
      end
    end

    def test_bad_cert
      assert_raises OpenSSL::X509::CertificateError do
        ::Cert::RhsmClient.new('This is not a real cert string.')
      end
    end
  end
end
